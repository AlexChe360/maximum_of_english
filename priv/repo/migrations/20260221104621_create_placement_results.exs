defmodule MaximumOfEnglish.Repo.Migrations.CreatePlacementResults do
  use Ecto.Migration

  def change do
    create table(:placement_results, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :score, :integer, null: false
      add :level, :string, null: false
      add :answers, :map, default: %{}

      timestamps(type: :utc_datetime)
    end
  end
end
