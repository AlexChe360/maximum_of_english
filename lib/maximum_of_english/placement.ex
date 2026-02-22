defmodule MaximumOfEnglish.Placement do
  @moduledoc """
  The Placement context. Manages placement tests and results.
  """

  import Ecto.Query
  alias MaximumOfEnglish.Repo

  alias MaximumOfEnglish.Placement.{
    PlacementTest,
    PlacementQuestion,
    PlacementAnswerOption,
    PlacementResult
  }

  # --- Placement Tests ---

  def get_active_test do
    PlacementTest
    |> where(is_active: true)
    |> limit(1)
    |> preload(questions: [options: ^from(o in PlacementAnswerOption, order_by: o.id)])
    |> Repo.one()
  end

  def list_tests do
    PlacementTest |> order_by(:inserted_at) |> Repo.all()
  end

  def get_test!(id) do
    PlacementTest
    |> preload(questions: [options: ^from(o in PlacementAnswerOption, order_by: o.id)])
    |> Repo.get!(id)
  end

  def create_test(attrs) do
    %PlacementTest{} |> PlacementTest.changeset(attrs) |> Repo.insert()
  end

  def update_test(%PlacementTest{} = test, attrs) do
    test |> PlacementTest.changeset(attrs) |> Repo.update()
  end

  def delete_test(%PlacementTest{} = test), do: Repo.delete(test)

  # --- Questions ---

  def create_question(attrs) do
    %PlacementQuestion{} |> PlacementQuestion.changeset(attrs) |> Repo.insert()
  end

  def delete_question(%PlacementQuestion{} = q), do: Repo.delete(q)

  # --- Options ---

  def create_option(attrs) do
    %PlacementAnswerOption{} |> PlacementAnswerOption.changeset(attrs) |> Repo.insert()
  end

  # --- Results ---

  def list_results do
    PlacementResult |> order_by([desc: :inserted_at]) |> Repo.all()
  end

  def create_result(attrs) do
    %PlacementResult{} |> PlacementResult.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Grades a placement test. Returns {score, total, level}.
  answers is a map %{question_id => selected_option_id}.
  """
  def grade_placement(test_id, answers) when is_map(answers) do
    test = get_test!(test_id)
    total = length(test.questions)

    correct =
      Enum.count(test.questions, fn question ->
        selected_id = Map.get(answers, question.id)
        Enum.any?(question.options, &(&1.id == selected_id && &1.is_correct))
      end)

    percentage = if total > 0, do: correct / total * 100, else: 0
    level = determine_level(percentage)

    {correct, total, level}
  end

  defp determine_level(percentage) do
    cond do
      percentage >= 90 -> "C1"
      percentage >= 75 -> "B2"
      percentage >= 60 -> "B1"
      percentage >= 40 -> "A2"
      percentage >= 20 -> "A1"
      true -> "Beginner"
    end
  end
end
