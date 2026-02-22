defmodule MaximumOfEnglish.Tests.LessonTest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lesson_tests" do
    belongs_to :lesson, MaximumOfEnglish.Courses.Lesson
    has_many :questions, MaximumOfEnglish.Tests.LessonTestQuestion

    timestamps(type: :utc_datetime)
  end

  def changeset(lesson_test, attrs) do
    lesson_test
    |> cast(attrs, [:lesson_id])
    |> validate_required([:lesson_id])
    |> unique_constraint(:lesson_id)
    |> foreign_key_constraint(:lesson_id)
  end
end
