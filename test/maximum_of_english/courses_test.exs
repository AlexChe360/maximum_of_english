defmodule MaximumOfEnglish.CoursesTest do
  use MaximumOfEnglish.DataCase

  alias MaximumOfEnglish.Courses

  describe "courses" do
    test "create_course/1 creates a course" do
      assert {:ok, course} = Courses.create_course(%{title: "English B1", is_active: true})
      assert course.title == "English B1"
      assert course.is_active == true
    end

    test "create_course/1 requires title" do
      assert {:error, changeset} = Courses.create_course(%{})
      assert "can't be blank" in errors_on(changeset).title
    end

    test "list_courses/0 returns all courses" do
      {:ok, _} = Courses.create_course(%{title: "Course 1"})
      {:ok, _} = Courses.create_course(%{title: "Course 2"})
      assert length(Courses.list_courses()) >= 2
    end

    test "update_course/2 updates attributes" do
      {:ok, course} = Courses.create_course(%{title: "Old Title"})
      {:ok, updated} = Courses.update_course(course, %{title: "New Title"})
      assert updated.title == "New Title"
    end

    test "delete_course/1 removes the course" do
      {:ok, course} = Courses.create_course(%{title: "To Delete"})
      {:ok, _} = Courses.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(course.id) end
    end
  end

  describe "weeks" do
    setup do
      {:ok, course} = Courses.create_course(%{title: "Test Course"})
      %{course: course}
    end

    test "create_week/1 creates a week", %{course: course} do
      assert {:ok, week} =
               Courses.create_week(%{course_id: course.id, number: 1, title: "Week 1"})

      assert week.number == 1
      assert week.is_unlocked == false
    end

    test "toggle_week_unlock/1 toggles unlock", %{course: course} do
      {:ok, week} = Courses.create_week(%{course_id: course.id, number: 1, title: "W1"})
      assert week.is_unlocked == false

      {:ok, week} = Courses.toggle_week_unlock(week)
      assert week.is_unlocked == true

      {:ok, week} = Courses.toggle_week_unlock(week)
      assert week.is_unlocked == false
    end
  end

  describe "lessons" do
    setup do
      {:ok, course} = Courses.create_course(%{title: "Test Course"})
      {:ok, week} = Courses.create_week(%{course_id: course.id, number: 1, title: "W1"})
      %{week: week}
    end

    test "create_lesson/1 with valid kind", %{week: week} do
      assert {:ok, lesson} =
               Courses.create_lesson(%{
                 week_id: week.id,
                 kind: "grammar",
                 title: "Grammar Lesson",
                 position: 1
               })

      assert lesson.kind == "grammar"
    end

    test "create_lesson/1 rejects invalid kind", %{week: week} do
      assert {:error, changeset} =
               Courses.create_lesson(%{
                 week_id: week.id,
                 kind: "invalid",
                 title: "Bad Lesson",
                 position: 1
               })

      assert "is invalid" in errors_on(changeset).kind
    end

    test "list_lessons_by_kind/2 filters by kind", %{week: week} do
      {:ok, _} = Courses.create_lesson(%{week_id: week.id, kind: "grammar", title: "G1", position: 1})
      {:ok, _} = Courses.create_lesson(%{week_id: week.id, kind: "reading", title: "R1", position: 1})
      {:ok, _} = Courses.create_lesson(%{week_id: week.id, kind: "reading", title: "R2", position: 2})

      grammar = Courses.list_lessons_by_kind(week.id, "grammar")
      reading = Courses.list_lessons_by_kind(week.id, "reading")

      assert length(grammar) == 1
      assert length(reading) == 2
    end
  end
end
