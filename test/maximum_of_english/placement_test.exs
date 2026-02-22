defmodule MaximumOfEnglish.PlacementContextTest do
  use MaximumOfEnglish.DataCase

  alias MaximumOfEnglish.Placement

  setup do
    {:ok, test} = Placement.create_test(%{title: "Test", is_active: true})

    questions =
      for i <- 1..5 do
        {:ok, q} = Placement.create_question(%{test_id: test.id, text: "Question #{i}?", position: i})

        {:ok, correct} = Placement.create_option(%{question_id: q.id, text: "Correct", is_correct: true})
        {:ok, _wrong} = Placement.create_option(%{question_id: q.id, text: "Wrong", is_correct: false})

        {q, correct}
      end

    %{placement_test: test, questions: questions}
  end

  describe "grade_placement/2" do
    test "scores 100% when all answers correct", ctx do
      answers =
        Map.new(ctx.questions, fn {q, correct} ->
          {q.id, correct.id}
        end)

      {score, total, level} = Placement.grade_placement(ctx.placement_test.id, answers)

      assert score == 5
      assert total == 5
      assert level == "C1"
    end

    test "scores 0% when no answers given", ctx do
      {score, total, level} = Placement.grade_placement(ctx.placement_test.id, %{})

      assert score == 0
      assert total == 5
      assert level == "Beginner"
    end

    test "determines correct level for partial scores", ctx do
      # Answer 3 out of 5 correctly = 60%
      correct_3 =
        ctx.questions
        |> Enum.take(3)
        |> Map.new(fn {q, correct} -> {q.id, correct.id} end)

      {score, _total, level} = Placement.grade_placement(ctx.placement_test.id, correct_3)

      assert score == 3
      assert level == "B1"
    end
  end

  describe "create_result/1" do
    test "saves placement result" do
      attrs = %{
        name: "John Doe",
        email: "john@example.com",
        phone: "+1234567890",
        score: 8,
        level: "B2",
        answers: %{"q1" => "a1"}
      }

      assert {:ok, result} = Placement.create_result(attrs)
      assert result.name == "John Doe"
      assert result.level == "B2"
      assert result.score == 8
    end

    test "requires name and email" do
      assert {:error, changeset} = Placement.create_result(%{score: 5, level: "A2"})
      assert "can't be blank" in errors_on(changeset).name
      assert "can't be blank" in errors_on(changeset).email
    end
  end
end
