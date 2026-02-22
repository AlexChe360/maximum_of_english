defmodule MaximumOfEnglish.Placement.PlacementTest do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "placement_tests" do
    field :title, :string
    field :description, :string
    field :is_active, :boolean, default: true

    has_many :questions, MaximumOfEnglish.Placement.PlacementQuestion, foreign_key: :test_id

    timestamps(type: :utc_datetime)
  end

  def changeset(test, attrs) do
    test
    |> cast(attrs, [:title, :description, :is_active])
    |> validate_required([:title])
  end
end
