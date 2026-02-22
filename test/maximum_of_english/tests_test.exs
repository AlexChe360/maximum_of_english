defmodule MaximumOfEnglish.TestsContextTest do
  use MaximumOfEnglish.DataCase

  alias MaximumOfEnglish.{Courses, Tests}

  setup do
    {:ok, course} = Courses.create_course(%{title: "Test Course"})
    {:ok, week} = Courses.create_week(%{course_id: course.id, number: 1, title: "W1", is_unlocked: true})
    {:ok, lesson} = Courses.create_lesson(%{week_id: week.id, kind: "grammar", title: "G1", position: 1})
    {:ok, test} = Tests.create_lesson_test(%{lesson_id: lesson.id})

    {:ok, q1} = Tests.create_question(%{lesson_test_id: test.id, text: "Q1?", position: 1})
    {:ok, q1_correct} = Tests.create_option(%{question_id: q1.id, text: "Correct", is_correct: true})
    {:ok, _q1_wrong} = Tests.create_option(%{question_id: q1.id, text: "Wrong", is_correct: false})

    {:ok, q2} = Tests.create_question(%{lesson_test_id: test.id, text: "Q2?", position: 2})
    {:ok, q2_correct} = Tests.create_option(%{question_id: q2.id, text: "Correct", is_correct: true})
    {:ok, q2_wrong} = Tests.create_option(%{question_id: q2.id, text: "Wrong", is_correct: false})

    {:ok, q3} = Tests.create_question(%{lesson_test_id: test.id, text: "Q3?", position: 3})
    {:ok, q3_correct} = Tests.create_option(%{question_id: q3.id, text: "Correct", is_correct: true})
    {:ok, _q3_wrong} = Tests.create_option(%{question_id: q3.id, text: "Wrong", is_correct: false})

    %{
      lesson_test: test,
      q1: q1, q1_correct: q1_correct,
      q2: q2, q2_correct: q2_correct, q2_wrong: q2_wrong,
      q3: q3, q3_correct: q3_correct
    }
  end

  describe "grade_test/2" do
    test "returns perfect score when all correct", ctx do
      answers = %{
        ctx.q1.id => ctx.q1_correct.id,
        ctx.q2.id => ctx.q2_correct.id,
        ctx.q3.id => ctx.q3_correct.id
      }

      {correct, total, passed} = Tests.grade_test(ctx.lesson_test.id, answers)

      assert correct == 3
      assert total == 3
      assert passed == true
    end

    test "fails when below 70%", ctx do
      answers = %{
        ctx.q1.id => ctx.q1_correct.id,
        ctx.q2.id => ctx.q2_wrong.id
        # q3 not answered
      }

      {correct, total, passed} = Tests.grade_test(ctx.lesson_test.id, answers)

      assert correct == 1
      assert total == 3
      assert passed == false
    end

    test "passes at exactly 70% (2/3 = 66.7% fails, 3/3 passes)", ctx do
      # 2 out of 3 = 66.7% - should fail
      answers = %{
        ctx.q1.id => ctx.q1_correct.id,
        ctx.q2.id => ctx.q2_correct.id
      }

      {correct, _total, passed} = Tests.grade_test(ctx.lesson_test.id, answers)
      assert correct == 2
      assert passed == false
    end
  end

  describe "create_matching_question/2" do
    test "creates a matching question with pairs", ctx do
      pairs = [
        %{left: "Hello", right: "Привет"},
        %{left: "Goodbye", right: "До свидания"},
        %{left: "Thank you", right: "Спасибо"}
      ]

      {:ok, question} =
        Tests.create_matching_question(%{lesson_test_id: ctx.lesson_test.id, text: "Match the words", position: 4}, pairs)

      assert question.question_type == "matching"

      reloaded = Tests.get_lesson_test!(ctx.lesson_test.id)
      matching_q = Enum.find(reloaded.questions, &(&1.id == question.id))
      assert length(matching_q.options) == 3
      assert Enum.all?(matching_q.options, &(&1.match_text != nil))
    end
  end

  describe "grade_test/2 with matching questions" do
    setup ctx do
      pairs = [
        %{left: "Cat", right: "Кот"},
        %{left: "Dog", right: "Собака"},
        %{left: "Bird", right: "Птица"}
      ]

      {:ok, matching_q} =
        Tests.create_matching_question(
          %{lesson_test_id: ctx.lesson_test.id, text: "Match animals", position: 4},
          pairs
        )

      # Reload to get the actual option order (sorted by UUID id)
      reloaded = Tests.get_lesson_test!(ctx.lesson_test.id)
      matching_loaded = Enum.find(reloaded.questions, &(&1.id == matching_q.id))
      correct_order = Enum.map(matching_loaded.options, & &1.match_text)

      ctx
      |> Map.put(:matching_q, matching_q)
      |> Map.put(:correct_order, correct_order)
    end

    test "perfect score with mixed question types", ctx do
      # 3 MC correct + 3 matching pairs correct = 6/6
      answers = %{
        ctx.q1.id => ctx.q1_correct.id,
        ctx.q2.id => ctx.q2_correct.id,
        ctx.q3.id => ctx.q3_correct.id,
        ctx.matching_q.id => ctx.correct_order
      }

      {score, total, passed} = Tests.grade_test(ctx.lesson_test.id, answers)
      assert score == 6
      assert total == 6
      assert passed == true
    end

    test "partial matching score causes failure", ctx do
      # Swap last two to get only 1 correct out of 3 pairs
      [first | rest] = ctx.correct_order
      wrong_order = [first | Enum.reverse(rest)]

      answers = %{
        ctx.q1.id => ctx.q1_correct.id,
        ctx.q2.id => ctx.q2_correct.id,
        ctx.q3.id => ctx.q3_correct.id,
        ctx.matching_q.id => wrong_order
      }

      {score, total, passed} = Tests.grade_test(ctx.lesson_test.id, answers)
      # 3 MC + 1 matching pair correct = 4/6 = 66.7%
      assert score == 4
      assert total == 6
      assert passed == false
    end

    test "all matching wrong", ctx do
      # Reverse all to get 0 correct (with 3 items, full reverse guarantees 0 matches only if no item stays in place)
      # Use a rotation instead: shift all items by 1
      wrong_order = Enum.slide(ctx.correct_order, 0, -1)

      answers = %{
        ctx.q1.id => ctx.q1_correct.id,
        ctx.q2.id => ctx.q2_correct.id,
        ctx.q3.id => ctx.q3_correct.id,
        ctx.matching_q.id => wrong_order
      }

      {score, total, passed} = Tests.grade_test(ctx.lesson_test.id, answers)
      # 3 MC + 0 matching = 3/6 = 50%
      assert score == 3
      assert total == 6
      assert passed == false
    end
  end
end
