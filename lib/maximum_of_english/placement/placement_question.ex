defmodule MaximumOfEnglish.Placement.PlacementQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "placement_questions" do
    field :text, :string
    field :position, :integer, default: 1

    belongs_to :test, MaximumOfEnglish.Placement.PlacementTest
    has_many :options, MaximumOfEnglish.Placement.PlacementAnswerOption, foreign_key: :question_id

    timestamps(type: :utc_datetime)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:test_id, :text, :position])
    |> validate_required([:test_id, :text, :position])
    |> foreign_key_constraint(:test_id)
  end
end
