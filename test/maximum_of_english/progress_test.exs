defmodule MaximumOfEnglish.ProgressTest do
  use MaximumOfEnglish.DataCase

  alias MaximumOfEnglish.{Courses, Progress}
  alias MaximumOfEnglish.Accounts.User

  setup do
    {:ok, student} =
      %User{}
      |> User.registration_changeset(%{
        email: "test_student_#{System.unique_integer([:positive])}@example.com",
        password: "test_password_123",
        role: "student"
      })
      |> Repo.insert()

    {:ok, course} = Courses.create_course(%{title: "Test Course", is_active: true})

    {:ok, week} =
      Courses.create_week(%{
        course_id: course.id,
        number: 1,
        title: "Week 1",
        is_unlocked: true
      })

    {:ok, grammar1} =
      Courses.create_lesson(%{week_id: week.id, kind: "grammar", title: "Grammar 1", position: 1})

    {:ok, reading1} =
      Courses.create_lesson(%{week_id: week.id, kind: "reading", title: "Reading 1", position: 1})

    {:ok, reading2} =
      Courses.create_lesson(%{week_id: week.id, kind: "reading", title: "Reading 2", position: 2})

    {:ok, listening1} =
      Courses.create_lesson(%{week_id: week.id, kind: "listening", title: "Listening 1", position: 1})

    {:ok, listening2} =
      Courses.create_lesson(%{week_id: week.id, kind: "listening", title: "Listening 2", position: 2})

    %{
      student: student,
      course: course,
      week: week,
      grammar1: grammar1,
      reading1: reading1,
      reading2: reading2,
      listening1: listening1,
      listening2: listening2
    }
  end

  describe "lesson_accessible?/3" do
    test "reading 1 and listening 1 are always accessible when week is unlocked", ctx do
      assert Progress.lesson_accessible?(ctx.student.id, ctx.reading1, ctx.week)
      assert Progress.lesson_accessible?(ctx.student.id, ctx.listening1, ctx.week)
    end

    test "reading 2 is locked until reading 1 is completed", ctx do
      refute Progress.lesson_accessible?(ctx.student.id, ctx.reading2, ctx.week)

      Progress.complete_lesson(ctx.student.id, ctx.reading1.id)

      assert Progress.lesson_accessible?(ctx.student.id, ctx.reading2, ctx.week)
    end

    test "listening 2 is locked until listening 1 is completed", ctx do
      refute Progress.lesson_accessible?(ctx.student.id, ctx.listening2, ctx.week)

      Progress.complete_lesson(ctx.student.id, ctx.listening1.id)

      assert Progress.lesson_accessible?(ctx.student.id, ctx.listening2, ctx.week)
    end

    test "grammar is locked until reading 1 AND listening 1 are completed", ctx do
      refute Progress.lesson_accessible?(ctx.student.id, ctx.grammar1, ctx.week)

      # Complete only reading 1
      Progress.complete_lesson(ctx.student.id, ctx.reading1.id)
      refute Progress.lesson_accessible?(ctx.student.id, ctx.grammar1, ctx.week)

      # Complete listening 1 too
      Progress.complete_lesson(ctx.student.id, ctx.listening1.id)
      assert Progress.lesson_accessible?(ctx.student.id, ctx.grammar1, ctx.week)
    end

    test "all lessons are locked when week is locked", ctx do
      locked_week = %{ctx.week | is_unlocked: false}

      refute Progress.lesson_accessible?(ctx.student.id, ctx.reading1, locked_week)
      refute Progress.lesson_accessible?(ctx.student.id, ctx.listening1, locked_week)
      refute Progress.lesson_accessible?(ctx.student.id, ctx.grammar1, locked_week)
    end
  end

  describe "complete_lesson/2" do
    test "marks a lesson as completed", ctx do
      refute Progress.lesson_completed?(ctx.student.id, ctx.reading1.id)

      {:ok, _} = Progress.complete_lesson(ctx.student.id, ctx.reading1.id)

      assert Progress.lesson_completed?(ctx.student.id, ctx.reading1.id)
    end

    test "is idempotent (completing twice doesn't error)", ctx do
      {:ok, _} = Progress.complete_lesson(ctx.student.id, ctx.reading1.id)
      {:ok, _} = Progress.complete_lesson(ctx.student.id, ctx.reading1.id)

      assert Progress.lesson_completed?(ctx.student.id, ctx.reading1.id)
    end
  end

  describe "completed_lesson_ids/2" do
    test "returns set of completed lesson IDs for a week", ctx do
      Progress.complete_lesson(ctx.student.id, ctx.reading1.id)
      Progress.complete_lesson(ctx.student.id, ctx.listening1.id)

      ids = Progress.completed_lesson_ids(ctx.student.id, ctx.week.id)

      assert MapSet.member?(ids, ctx.reading1.id)
      assert MapSet.member?(ids, ctx.listening1.id)
      refute MapSet.member?(ids, ctx.grammar1.id)
    end
  end
end
