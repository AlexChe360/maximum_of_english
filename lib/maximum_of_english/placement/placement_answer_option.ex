defmodule MaximumOfEnglish.Placement.PlacementAnswerOption do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "placement_answer_options" do
    field :text, :string
    field :is_correct, :boolean, default: false

    belongs_to :question, MaximumOfEnglish.Placement.PlacementQuestion

    timestamps(type: :utc_datetime)
  end

  def changeset(option, attrs) do
    option
    |> cast(attrs, [:question_id, :text, :is_correct])
    |> validate_required([:question_id, :text])
    |> foreign_key_constraint(:question_id)
  end
end
