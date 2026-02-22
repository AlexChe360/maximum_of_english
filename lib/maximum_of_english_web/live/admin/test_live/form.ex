defmodule MaximumOfEnglishWeb.Admin.TestLive.Form do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.{Courses, Tests}

  @impl true
  def mount(%{"lesson_id" => lesson_id}, _session, socket) do
    lesson = Courses.get_lesson!(lesson_id)
    test = Tests.get_test_for_lesson(lesson_id)

    socket =
      socket
      |> assign(page_title: "Test — #{lesson.title}")
      |> assign(lesson: lesson)
      |> assign(test: test)
      |> assign(new_question_text: "")
      |> assign(new_options: %{})
      |> assign(adding_question: false)
      |> assign(new_question_type: "multiple_choice")
      |> assign(matching_pairs: [%{left: "", right: ""}])

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Test — {@lesson.title}
        <:subtitle>Manage test questions and answer options.</:subtitle>
      </.header>

      <%= if @test do %>
        <%!-- Existing questions --%>
        <div class="space-y-4 mb-6">
          <%= for question <- @test.questions do %>
            <div class="card bg-base-200 shadow-sm">
              <div class="card-body">
                <div class="flex justify-between items-start">
                  <div class="flex items-center gap-2">
                    <p class="font-medium">{question.position}. {question.text}</p>
                    <span :if={question.question_type == "matching"} class="badge badge-info badge-sm">Matching</span>
                  </div>
                  <button phx-click="delete_question" phx-value-id={question.id} data-confirm="Delete this question?" class="btn btn-ghost btn-xs text-error">
                    <.icon name="hero-trash" class="size-4" />
                  </button>
                </div>

                <%= if question.question_type == "matching" do %>
                  <%!-- Matching pairs display --%>
                  <div class="ml-4 space-y-1">
                    <%= for option <- question.options do %>
                      <div class="flex items-center gap-2">
                        <span class="badge badge-sm badge-outline">{option.text}</span>
                        <.icon name="hero-arrow-right" class="size-3 opacity-50" />
                        <span class="badge badge-sm badge-outline">{option.match_text}</span>
                        <button phx-click="delete_option" phx-value-id={option.id} class="btn btn-ghost btn-xs text-error">
                          <.icon name="hero-x-mark" class="size-3" />
                        </button>
                      </div>
                    <% end %>
                  </div>

                  <%!-- Add pair to existing matching question --%>
                  <form phx-submit="add_matching_pair_to_question" class="flex items-end gap-2 mt-2">
                    <input type="hidden" name="question_id" value={question.id} />
                    <div class="flex-1">
                      <input type="text" name="left" placeholder="Left side" class="input input-sm w-full" required />
                    </div>
                    <div class="flex-1">
                      <input type="text" name="right" placeholder="Right side" class="input input-sm w-full" required />
                    </div>
                    <button type="submit" class="btn btn-sm btn-outline">Add Pair</button>
                  </form>
                <% else %>
                  <%!-- Multiple choice options display --%>
                  <div class="ml-4 space-y-1">
                    <%= for option <- question.options do %>
                      <div class="flex items-center gap-2">
                        <span class={"badge badge-sm #{if option.is_correct, do: "badge-success", else: "badge-ghost"}"}>
                          {if option.is_correct, do: "Correct", else: "Wrong"}
                        </span>
                        <span class="text-sm">{option.text}</span>
                        <button phx-click="delete_option" phx-value-id={option.id} class="btn btn-ghost btn-xs text-error">
                          <.icon name="hero-x-mark" class="size-3" />
                        </button>
                      </div>
                    <% end %>
                  </div>

                  <%!-- Add option form --%>
                  <form phx-submit="add_option" class="flex items-end gap-2 mt-2">
                    <input type="hidden" name="question_id" value={question.id} />
                    <div class="flex-1">
                      <input type="text" name="text" placeholder="New option text" class="input input-sm w-full" required />
                    </div>
                    <label class="flex items-center gap-1 text-sm">
                      <input type="checkbox" name="is_correct" value="true" class="checkbox checkbox-sm checkbox-success" />
                      Correct
                    </label>
                    <button type="submit" class="btn btn-sm btn-outline">Add Option</button>
                  </form>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>

        <%!-- Add question form --%>
        <div class="card bg-base-200 shadow-sm">
          <div class="card-body">
            <h3 class="card-title text-base">Add Question</h3>

            <%!-- Question type selector --%>
            <div class="flex gap-4 mb-2">
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="question_type"
                  value="multiple_choice"
                  checked={@new_question_type == "multiple_choice"}
                  phx-click="set_question_type"
                  phx-value-type="multiple_choice"
                  class="radio radio-sm radio-primary"
                />
                <span class="text-sm">Multiple Choice</span>
              </label>
              <label class="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="question_type"
                  value="matching"
                  checked={@new_question_type == "matching"}
                  phx-click="set_question_type"
                  phx-value-type="matching"
                  class="radio radio-sm radio-primary"
                />
                <span class="text-sm">Matching</span>
              </label>
            </div>

            <%= if @new_question_type == "multiple_choice" do %>
              <form phx-submit="add_question" class="flex items-end gap-2">
                <div class="flex-1">
                  <input type="text" name="text" placeholder="Question text" class="input w-full" required />
                </div>
                <div class="w-20">
                  <input type="number" name="position" value={length(@test.questions) + 1} class="input w-full" min="1" />
                </div>
                <button type="submit" class="btn btn-primary">Add</button>
              </form>
            <% else %>
              <form phx-submit="add_matching_question">
                <div class="flex items-end gap-2 mb-3">
                  <div class="flex-1">
                    <input type="text" name="text" placeholder="Question text (e.g., Match the words)" class="input w-full" required />
                  </div>
                  <div class="w-20">
                    <input type="number" name="position" value={length(@test.questions) + 1} class="input w-full" min="1" />
                  </div>
                </div>

                <div class="space-y-2 mb-3">
                  <p class="text-sm font-medium">Pairs:</p>
                  <%= for {pair, idx} <- Enum.with_index(@matching_pairs) do %>
                    <div class="flex items-center gap-2">
                      <input
                        type="text"
                        name={"pairs[#{idx}][left]"}
                        value={pair.left}
                        placeholder="Left side"
                        class="input input-sm flex-1"
                        required
                      />
                      <.icon name="hero-arrow-right" class="size-4 opacity-50" />
                      <input
                        type="text"
                        name={"pairs[#{idx}][right]"}
                        value={pair.right}
                        placeholder="Right side"
                        class="input input-sm flex-1"
                        required
                      />
                      <button
                        :if={length(@matching_pairs) > 1}
                        type="button"
                        phx-click="remove_matching_pair"
                        phx-value-index={idx}
                        class="btn btn-ghost btn-xs text-error"
                      >
                        <.icon name="hero-x-mark" class="size-4" />
                      </button>
                    </div>
                  <% end %>
                  <button type="button" phx-click="add_matching_pair" class="btn btn-ghost btn-xs">
                    <.icon name="hero-plus" class="size-3" /> Add Pair
                  </button>
                </div>

                <button type="submit" class="btn btn-primary">Add Matching Question</button>
              </form>
            <% end %>
          </div>
        </div>

        <div class="mt-4">
          <button phx-click="delete_test" data-confirm="Delete entire test?" class="btn btn-error btn-sm">
            <.icon name="hero-trash" class="size-4" /> Delete Test
          </button>
        </div>
      <% else %>
        <div class="card bg-base-200 shadow-sm">
          <div class="card-body text-center">
            <p class="text-base-content/70 mb-4">No test exists for this lesson yet.</p>
            <button phx-click="create_test" class="btn btn-primary">
              <.icon name="hero-plus" class="size-4" /> Create Test
            </button>
          </div>
        </div>
      <% end %>

      <.link navigate={~p"/admin/weeks/#{@lesson.week_id}/lessons"} class="btn btn-ghost btn-sm mt-4">
        <.icon name="hero-arrow-left" class="size-4" /> Back to Lessons
      </.link>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("create_test", _params, socket) do
    {:ok, test} = Tests.create_lesson_test(%{lesson_id: socket.assigns.lesson.id})
    test = Tests.get_lesson_test!(test.id)
    {:noreply, assign(socket, test: test)}
  end

  @impl true
  def handle_event("delete_test", _params, socket) do
    {:ok, _} = Tests.delete_lesson_test(socket.assigns.test)
    {:noreply, assign(socket, test: nil)}
  end

  @impl true
  def handle_event("set_question_type", %{"type" => type}, socket) do
    {:noreply, assign(socket, new_question_type: type)}
  end

  # --- Multiple Choice ---

  @impl true
  def handle_event("add_question", %{"text" => text, "position" => position}, socket) do
    {:ok, _} =
      Tests.create_question(%{
        lesson_test_id: socket.assigns.test.id,
        text: text,
        position: String.to_integer(position)
      })

    test = Tests.get_lesson_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end

  @impl true
  def handle_event("delete_question", %{"id" => id}, socket) do
    question = %Tests.LessonTestQuestion{id: id}
    {:ok, _} = Tests.delete_question(question)
    test = Tests.get_lesson_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end

  @impl true
  def handle_event("add_option", params, socket) do
    {:ok, _} =
      Tests.create_option(%{
        question_id: params["question_id"],
        text: params["text"],
        is_correct: params["is_correct"] == "true"
      })

    test = Tests.get_lesson_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end

  @impl true
  def handle_event("delete_option", %{"id" => id}, socket) do
    option = %Tests.LessonTestOption{id: id}
    {:ok, _} = Tests.delete_option(option)
    test = Tests.get_lesson_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end

  # --- Matching ---

  @impl true
  def handle_event("add_matching_pair", _params, socket) do
    pairs = socket.assigns.matching_pairs ++ [%{left: "", right: ""}]
    {:noreply, assign(socket, matching_pairs: pairs)}
  end

  @impl true
  def handle_event("remove_matching_pair", %{"index" => index}, socket) do
    idx = String.to_integer(index)
    pairs = List.delete_at(socket.assigns.matching_pairs, idx)
    {:noreply, assign(socket, matching_pairs: pairs)}
  end

  @impl true
  def handle_event("add_matching_question", %{"text" => text, "position" => position} = params, socket) do
    pairs =
      params
      |> Map.get("pairs", %{})
      |> Enum.sort_by(fn {k, _v} -> String.to_integer(k) end)
      |> Enum.map(fn {_k, v} -> %{left: v["left"], right: v["right"]} end)

    {:ok, _} =
      Tests.create_matching_question(
        %{
          lesson_test_id: socket.assigns.test.id,
          text: text,
          position: String.to_integer(position)
        },
        pairs
      )

    test = Tests.get_lesson_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test, matching_pairs: [%{left: "", right: ""}])}
  end

  @impl true
  def handle_event("add_matching_pair_to_question", %{"question_id" => qid, "left" => left, "right" => right}, socket) do
    {:ok, _} =
      Tests.create_option(%{
        question_id: qid,
        text: left,
        match_text: right,
        is_correct: true
      })

    test = Tests.get_lesson_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end
end
