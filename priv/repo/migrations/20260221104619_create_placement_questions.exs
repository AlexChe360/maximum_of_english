defmodule MaximumOfEnglish.Repo.Migrations.CreatePlacementQuestions do
  use Ecto.Migration

  def change do
    create table(:placement_questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :test_id, references(:placement_tests, type: :binary_id, on_delete: :delete_all),
        null: false
      add :text, :text, null: false
      add :position, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:placement_questions, [:test_id])
  end
end
