defmodule MaximumOfEnglish.Courses.Week do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "weeks" do
    field :number, :integer
    field :title, :string
    field :is_unlocked, :boolean, default: false

    belongs_to :course, MaximumOfEnglish.Courses.Course
    has_many :lessons, MaximumOfEnglish.Courses.Lesson

    timestamps(type: :utc_datetime)
  end

  def changeset(week, attrs) do
    week
    |> cast(attrs, [:course_id, :number, :title, :is_unlocked])
    |> validate_required([:course_id, :number, :title])
    |> unique_constraint([:course_id, :number])
    |> foreign_key_constraint(:course_id)
  end
end
