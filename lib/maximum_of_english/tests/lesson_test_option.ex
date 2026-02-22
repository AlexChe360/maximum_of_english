defmodule MaximumOfEnglish.Tests.LessonTestOption do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lesson_test_options" do
    field :text, :string
    field :is_correct, :boolean, default: false
    field :match_text, :string

    belongs_to :question, MaximumOfEnglish.Tests.LessonTestQuestion

    timestamps(type: :utc_datetime)
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, [:question_id, :text, :is_correct, :match_text])
    |> validate_required([:question_id, :text])
    |> foreign_key_constraint(:question_id)
  end
end
