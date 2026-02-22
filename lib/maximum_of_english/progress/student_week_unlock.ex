defmodule MaximumOfEnglish.Progress.StudentWeekUnlock do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "student_week_unlocks" do
    belongs_to :student, MaximumOfEnglish.Accounts.User
    belongs_to :week, MaximumOfEnglish.Courses.Week

    timestamps(type: :utc_datetime)
  end

  def changeset(unlock, attrs) do
    unlock
    |> cast(attrs, [:student_id, :week_id])
    |> validate_required([:student_id, :week_id])
    |> unique_constraint([:student_id, :week_id])
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:week_id)
  end
end
