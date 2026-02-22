defmodule MaximumOfEnglish.Repo.Migrations.CreateWeeks do
  use Ecto.Migration

  def change do
    create table(:weeks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :course_id, references(:courses, type: :binary_id, on_delete: :delete_all), null: false
      add :number, :integer, null: false
      add :title, :string, null: false
      add :is_unlocked, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:weeks, [:course_id])
    create unique_index(:weeks, [:course_id, :number])
  end
end
