defmodule MaximumOfEnglish.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :week_id, references(:weeks, type: :binary_id, on_delete: :delete_all), null: false
      add :kind, :string, null: false
      add :title, :string, null: false
      add :description, :text
      add :file_url, :string
      add :video_url, :string
      add :audio_url, :string
      add :image_url, :string
      add :vocabulary, :text
      add :position, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:week_id])
    create unique_index(:lessons, [:week_id, :kind, :position])
  end
end
