defmodule MaximumOfEnglish.Placement.PlacementResult do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "placement_results" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :score, :integer
    field :level, :string
    field :answers, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(result, attrs) do
    result
    |> cast(attrs, [:name, :email, :phone, :score, :level, :answers])
    |> validate_required([:name, :email, :score, :level])
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/)
  end
end
