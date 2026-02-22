defmodule MaximumOfEnglish.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "courses" do
    field :title, :string
    field :description, :string
    field :is_active, :boolean, default: true

    has_many :weeks, MaximumOfEnglish.Courses.Week

    timestamps(type: :utc_datetime)
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:title, :description, :is_active])
    |> validate_required([:title])
  end
end
