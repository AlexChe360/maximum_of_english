defmodule MaximumOfEnglish.Progress do
  @moduledoc """
  The Progress context. Tracks student lesson completion and handles unlock logic.
  """

  import Ecto.Query
  alias MaximumOfEnglish.Repo
  alias MaximumOfEnglish.Progress.{StudentLessonProgress, StudentWeekUnlock}
  alias MaximumOfEnglish.Courses
  alias MaximumOfEnglish.Courses.{Lesson, Week}

  # --- Lesson Completion ---

  def complete_lesson(student_id, lesson_id) do
    attrs = %{
      student_id: student_id,
      lesson_id: lesson_id,
      completed_at: DateTime.utc_now(:second)
    }

    %StudentLessonProgress{}
    |> StudentLessonProgress.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:student_id, :lesson_id])
  end

  def lesson_completed?(student_id, lesson_id) do
    StudentLessonProgress
    |> where(student_id: ^student_id, lesson_id: ^lesson_id)
    |> Repo.exists?()
  end

  def completed_lesson_ids(student_id, week_id) do
    from(p in StudentLessonProgress,
      join: l in Lesson, on: l.id == p.lesson_id,
      where: p.student_id == ^student_id and l.week_id == ^week_id,
      select: p.lesson_id
    )
    |> Repo.all()
    |> MapSet.new()
  end

  def completed_count(student_id, week_id) do
    from(p in StudentLessonProgress,
      join: l in Lesson, on: l.id == p.lesson_id,
      where: p.student_id == ^student_id and l.week_id == ^week_id,
      select: count(p.id)
    )
    |> Repo.one()
  end

  def total_lessons_count(week_id) do
    Lesson |> where(week_id: ^week_id) |> Repo.aggregate(:count)
  end

  # --- Lesson Accessibility ---

  def lesson_accessible?(student_id, %Lesson{} = lesson, week) do
    cond do
      not week_accessible?(student_id, week) ->
        false

      lesson.kind in ["reading", "listening"] and lesson.position > 1 ->
        previous = get_previous_lesson(lesson)
        previous != nil and lesson_completed?(student_id, previous.id)

      lesson.kind == "grammar" ->
        first_reading = Courses.get_first_lesson_of_kind(lesson.week_id, "reading")
        first_listening = Courses.get_first_lesson_of_kind(lesson.week_id, "listening")

        reading_done =
          is_nil(first_reading) or lesson_completed?(student_id, first_reading.id)

        listening_done =
          is_nil(first_listening) or lesson_completed?(student_id, first_listening.id)

        reading_done and listening_done

      true ->
        true
    end
  end

  def week_accessible?(student_id, week) do
    week.is_unlocked or week_unlocked_for_student?(student_id, week.id)
  end

  defp get_previous_lesson(%Lesson{week_id: week_id, kind: kind, position: pos}) when pos > 1 do
    Lesson
    |> where(week_id: ^week_id, kind: ^kind, position: ^(pos - 1))
    |> Repo.one()
  end

  defp get_previous_lesson(_), do: nil

  # --- Per-Student Week Unlocking ---

  def week_unlocked_for_student?(student_id, week_id) do
    StudentWeekUnlock
    |> where(student_id: ^student_id, week_id: ^week_id)
    |> Repo.exists?()
  end

  def unlock_week_for_student(student_id, week_id) do
    %StudentWeekUnlock{}
    |> StudentWeekUnlock.changeset(%{student_id: student_id, week_id: week_id})
    |> Repo.insert(on_conflict: :nothing, conflict_target: [:student_id, :week_id])
  end

  def lock_week_for_student(student_id, week_id) do
    StudentWeekUnlock
    |> where(student_id: ^student_id, week_id: ^week_id)
    |> Repo.delete_all()

    :ok
  end

  def student_week_unlock_ids(student_id) do
    StudentWeekUnlock
    |> where(student_id: ^student_id)
    |> select([u], u.week_id)
    |> Repo.all()
    |> MapSet.new()
  end

  @doc """
  After a lesson is completed, check if all lessons in the week are done.
  If so, auto-unlock the next week (by number) in the same course.
  """
  def maybe_auto_unlock_next_week(student_id, %Lesson{week_id: week_id}) do
    total = total_lessons_count(week_id)
    completed = completed_count(student_id, week_id)

    if total > 0 and completed >= total do
      week = Courses.get_week!(week_id)

      next_week =
        Week
        |> where(course_id: ^week.course_id)
        |> where([w], w.number > ^week.number)
        |> order_by(:number)
        |> limit(1)
        |> Repo.one()

      if next_week do
        unlock_week_for_student(student_id, next_week.id)
      end
    end

    :ok
  end
end
