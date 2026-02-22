defmodule MaximumOfEnglish.Repo.Migrations.CreateLessonTestQuestions do
  use Ecto.Migration

  def change do
    create table(:lesson_test_questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :lesson_test_id, references(:lesson_tests, type: :binary_id, on_delete: :delete_all),
        null: false
      add :text, :text, null: false
      add :position, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_test_questions, [:lesson_test_id])
  end
end
