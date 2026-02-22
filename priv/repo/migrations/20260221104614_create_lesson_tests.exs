defmodule MaximumOfEnglish.Repo.Migrations.CreateLessonTests do
  use Ecto.Migration

  def change do
    create table(:lesson_tests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :lesson_id, references(:lessons, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:lesson_tests, [:lesson_id])
  end
end
