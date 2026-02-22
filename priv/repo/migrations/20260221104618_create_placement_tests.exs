defmodule MaximumOfEnglish.Repo.Migrations.CreatePlacementTests do
  use Ecto.Migration

  def change do
    create table(:placement_tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
