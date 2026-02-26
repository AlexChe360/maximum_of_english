defmodule MaximumOfEnglish.Repo.Migrations.AddLevelToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :level, :string
    end
  end
end
