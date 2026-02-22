defmodule MaximumOfEnglish.Courses do
  @moduledoc """
  The Courses context. Manages courses, weeks, and lessons.
  """

  import Ecto.Query
  alias MaximumOfEnglish.Repo
  alias MaximumOfEnglish.Courses.{Course, Week, Lesson}

  # --- Courses ---

  def list_courses do
    Course |> order_by(:inserted_at) |> Repo.all()
  end

  def list_active_courses do
    Course |> where(is_active: true) |> order_by(:inserted_at) |> Repo.all()
  end

  def get_course!(id), do: Repo.get!(Course, id)

  def create_course(attrs) do
    %Course{} |> Course.changeset(attrs) |> Repo.insert()
  end

  def update_course(%Course{} = course, attrs) do
    course |> Course.changeset(attrs) |> Repo.update()
  end

  def delete_course(%Course{} = course), do: Repo.delete(course)

  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  # --- Weeks ---

  def list_weeks(course_id) do
    Week
    |> where(course_id: ^course_id)
    |> order_by(:number)
    |> Repo.all()
  end

  def list_weeks_with_lessons(course_id) do
    Week
    |> where(course_id: ^course_id)
    |> order_by(:number)
    |> preload(lessons: ^from(l in Lesson, order_by: [l.kind, l.position]))
    |> Repo.all()
  end

  def get_week!(id), do: Repo.get!(Week, id)

  def get_week_with_lessons!(id) do
    Week
    |> preload(lessons: ^from(l in Lesson, order_by: [l.kind, l.position]))
    |> Repo.get!(id)
  end

  def create_week(attrs) do
    %Week{} |> Week.changeset(attrs) |> Repo.insert()
  end

  def update_week(%Week{} = week, attrs) do
    week |> Week.changeset(attrs) |> Repo.update()
  end

  def toggle_week_unlock(%Week{} = week) do
    week |> Week.changeset(%{is_unlocked: !week.is_unlocked}) |> Repo.update()
  end

  def delete_week(%Week{} = week), do: Repo.delete(week)

  def change_week(%Week{} = week, attrs \\ %{}) do
    Week.changeset(week, attrs)
  end

  # --- Lessons ---

  def list_lessons(week_id) do
    Lesson
    |> where(week_id: ^week_id)
    |> order_by([:kind, :position])
    |> Repo.all()
  end

  def list_lessons_by_kind(week_id, kind) do
    Lesson
    |> where(week_id: ^week_id, kind: ^kind)
    |> order_by(:position)
    |> Repo.all()
  end

  def get_lesson!(id), do: Repo.get!(Lesson, id)

  def get_lesson_with_test!(id) do
    Lesson
    |> preload(lesson_test: [questions: [options: ^from(o in MaximumOfEnglish.Tests.LessonTestOption, order_by: o.id)]])
    |> Repo.get!(id)
  end

  def create_lesson(attrs) do
    %Lesson{} |> Lesson.changeset(attrs) |> Repo.insert()
  end

  def update_lesson(%Lesson{} = lesson, attrs) do
    lesson |> Lesson.changeset(attrs) |> Repo.update()
  end

  def delete_lesson(%Lesson{} = lesson) do
    alias MaximumOfEnglish.Uploads

    Uploads.delete_file(lesson.video_url)
    Uploads.delete_file(lesson.audio_url)
    Uploads.delete_file(lesson.image_url)
    Uploads.delete_file(lesson.file_url)
    Repo.delete(lesson)
  end

  def change_lesson(%Lesson{} = lesson, attrs \\ %{}) do
    Lesson.changeset(lesson, attrs)
  end

  def get_first_lesson_of_kind(week_id, kind) do
    Lesson
    |> where(week_id: ^week_id, kind: ^kind)
    |> order_by(:position)
    |> limit(1)
    |> Repo.one()
  end
end
