defmodule MaximumOfEnglish.Repo.Migrations.AddQuestionTypeAndMatchText do
  use Ecto.Migration

  def change do
    alter table(:lesson_test_questions) do
      add :question_type, :string, null: false, default: "multiple_choice"
    end

    alter table(:lesson_test_options) do
      add :match_text, :string
    end
  end
end
