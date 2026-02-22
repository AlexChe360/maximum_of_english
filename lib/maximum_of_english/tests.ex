defmodule MaximumOfEnglish.Tests do
  @moduledoc """
  The Tests context. Manages lesson tests, questions, and options.
  """

  import Ecto.Query
  alias MaximumOfEnglish.Repo
  alias MaximumOfEnglish.Tests.{LessonTest, LessonTestQuestion, LessonTestOption}

  # --- Lesson Tests ---

  def get_test_for_lesson(lesson_id) do
    LessonTest
    |> where(lesson_id: ^lesson_id)
    |> preload(questions: [options: ^from(o in LessonTestOption, order_by: o.id)])
    |> Repo.one()
  end

  def get_lesson_test!(id) do
    LessonTest
    |> preload(questions: [options: ^from(o in LessonTestOption, order_by: o.id)])
    |> Repo.get!(id)
  end

  def create_lesson_test(attrs) do
    %LessonTest{} |> LessonTest.changeset(attrs) |> Repo.insert()
  end

  def delete_lesson_test(%LessonTest{} = test), do: Repo.delete(test)

  # --- Questions ---

  def create_question(attrs) do
    %LessonTestQuestion{} |> LessonTestQuestion.changeset(attrs) |> Repo.insert()
  end

  def update_question(%LessonTestQuestion{} = question, attrs) do
    question |> LessonTestQuestion.changeset(attrs) |> Repo.update()
  end

  def delete_question(%LessonTestQuestion{} = question), do: Repo.delete(question)

  # --- Options ---

  def create_option(attrs) do
    %LessonTestOption{} |> LessonTestOption.changeset(attrs) |> Repo.insert()
  end

  def update_option(%LessonTestOption{} = option, attrs) do
    option |> LessonTestOption.changeset(attrs) |> Repo.update()
  end

  def delete_option(%LessonTestOption{} = option), do: Repo.delete(option)

  @doc """
  Creates a matching question with pairs. Each pair is %{left: text, right: match_text}.
  """
  def create_matching_question(attrs, pairs) do
    Repo.transaction(fn ->
      case create_question(Map.put(attrs, :question_type, "matching")) do
        {:ok, question} ->
          Enum.each(pairs, fn pair ->
            {:ok, _} =
              create_option(%{
                question_id: question.id,
                text: pair.left,
                match_text: pair.right,
                is_correct: true
              })
          end)

          question

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Grades a test submission. Returns {score, total, passed?}.
  For multiple_choice: answers is %{question_id => selected_option_id}.
  For matching: answers is %{question_id => [match_text, ...]}, an ordered list
  of match_texts that the student placed (in order matching the options sorted by id).
  Pass threshold is 70%.
  """
  def grade_test(lesson_test_id, answers) when is_map(answers) do
    test = get_lesson_test!(lesson_test_id)

    {score, total} =
      Enum.reduce(test.questions, {0, 0}, fn question, {score_acc, total_acc} ->
        case question.question_type do
          "multiple_choice" ->
            selected_id = Map.get(answers, question.id)
            correct = if Enum.any?(question.options, &(&1.id == selected_id && &1.is_correct)), do: 1, else: 0
            {score_acc + correct, total_acc + 1}

          "matching" ->
            correct_order = Enum.map(question.options, & &1.match_text)
            student_order = Map.get(answers, question.id, [])
            pair_count = length(correct_order)

            pair_score =
              correct_order
              |> Enum.zip(student_order)
              |> Enum.count(fn {correct, student} -> correct == student end)

            {score_acc + pair_score, total_acc + pair_count}
        end
      end)

    passed = total > 0 and score / total >= 0.7
    {score, total, passed}
  end
end
