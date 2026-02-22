defmodule MaximumOfEnglish.Progress.StudentLessonProgress do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "student_lesson_progresses" do
    field :completed_at, :utc_datetime

    belongs_to :student, MaximumOfEnglish.Accounts.User
    belongs_to :lesson, MaximumOfEnglish.Courses.Lesson

    timestamps(type: :utc_datetime)
  end

  def changeset(progress, attrs) do
    progress
    |> cast(attrs, [:student_id, :lesson_id, :completed_at])
    |> validate_required([:student_id, :lesson_id, :completed_at])
    |> unique_constraint([:student_id, :lesson_id])
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:lesson_id)
  end
end
