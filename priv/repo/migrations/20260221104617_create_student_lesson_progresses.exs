defmodule MaximumOfEnglish.Repo.Migrations.CreateStudentLessonProgresses do
  use Ecto.Migration

  def change do
    create table(:student_lesson_progresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :student_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :lesson_id, references(:lessons, type: :binary_id, on_delete: :delete_all), null: false
      add :completed_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:student_lesson_progresses, [:student_id, :lesson_id])
    create index(:student_lesson_progresses, [:student_id])
  end
end
