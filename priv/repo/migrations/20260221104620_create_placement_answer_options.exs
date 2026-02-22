defmodule MaximumOfEnglish.Repo.Migrations.CreatePlacementAnswerOptions do
  use Ecto.Migration

  def change do
    create table(:placement_answer_options, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :question_id,
        references(:placement_questions, type: :binary_id, on_delete: :delete_all),
        null: false
      add :text, :string, null: false
      add :is_correct, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:placement_answer_options, [:question_id])
  end
end
