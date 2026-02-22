defmodule MaximumOfEnglish.Tests.LessonTestQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lesson_test_questions" do
    field :text, :string
    field :position, :integer, default: 1
    field :question_type, :string, default: "multiple_choice"

    belongs_to :lesson_test, MaximumOfEnglish.Tests.LessonTest
    has_many :options, MaximumOfEnglish.Tests.LessonTestOption, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:lesson_test_id, :text, :position, :question_type])
    |> validate_required([:lesson_test_id, :text, :position])
    |> validate_inclusion(:question_type, ~w(multiple_choice matching))
    |> foreign_key_constraint(:lesson_test_id)
  end
end
