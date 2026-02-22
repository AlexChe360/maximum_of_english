defmodule MaximumOfEnglish.Repo.Migrations.CreateStudentWeekUnlocks do
  use Ecto.Migration

  def change do
    create table(:student_week_unlocks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :student_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :week_id, references(:weeks, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:student_week_unlocks, [:student_id, :week_id])
  end
end
