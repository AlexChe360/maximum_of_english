defmodule MaximumOfEnglishWeb.Admin.PlacementTestLive.Form do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Placement
  alias MaximumOfEnglish.Placement.{PlacementQuestion, PlacementAnswerOption}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    test = Placement.get_test!(id)

    socket =
      socket
      |> assign(page_title: "Edit — #{test.title}")
      |> assign(test: test)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@test.title}
        <:subtitle>Manage placement test questions and answer options.</:subtitle>
      </.header>

      <%!-- Edit title & active status --%>
      <div class="card bg-base-200 shadow-sm mb-6">
        <div class="card-body">
          <form phx-submit="update_test" class="flex items-end gap-4">
            <div class="flex-1">
              <label class="label text-sm">Title</label>
              <input type="text" name="title" value={@test.title} class="input w-full" required />
            </div>
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                name="is_active"
                value="true"
                checked={@test.is_active}
                class="checkbox checkbox-success"
              />
              <span class="text-sm">Active</span>
            </label>
            <button type="submit" class="btn btn-primary btn-sm">Save</button>
          </form>
        </div>
      </div>

      <%!-- Existing questions --%>
      <div class="space-y-4 mb-6">
        <%= for question <- @test.questions do %>
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body">
              <div class="flex justify-between items-start">
                <p class="font-medium">{question.position}. {question.text}</p>
                <button phx-click="delete_question" phx-value-id={question.id} data-confirm="Delete this question?" class="btn btn-ghost btn-xs text-error">
                  <.icon name="hero-trash" class="size-4" />
                </button>
              </div>

              <%!-- Options display --%>
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
            </div>
          </div>
        <% end %>
      </div>

      <%!-- Add question form --%>
      <div class="card bg-base-200 shadow-sm">
        <div class="card-body">
          <h3 class="card-title text-base">Add Question</h3>
          <form phx-submit="add_question" class="flex items-end gap-2">
            <div class="flex-1">
              <input type="text" name="text" placeholder="Question text" class="input w-full" required />
            </div>
            <div class="w-20">
              <input type="number" name="position" value={length(@test.questions) + 1} class="input w-full" min="1" />
            </div>
            <button type="submit" class="btn btn-primary">Add</button>
          </form>
        </div>
      </div>

      <.link navigate={~p"/admin/placement-tests"} class="btn btn-ghost btn-sm mt-4">
        <.icon name="hero-arrow-left" class="size-4" /> Back
      </.link>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("update_test", params, socket) do
    attrs = %{
      title: params["title"],
      is_active: params["is_active"] == "true"
    }

    {:ok, _} = Placement.update_test(socket.assigns.test, attrs)
    test = Placement.get_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test, page_title: "Edit — #{test.title}")}
  end

  @impl true
  def handle_event("add_question", %{"text" => text, "position" => position}, socket) do
    {:ok, _} =
      Placement.create_question(%{
        test_id: socket.assigns.test.id,
        text: text,
        position: String.to_integer(position)
      })

    test = Placement.get_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end

  @impl true
  def handle_event("delete_question", %{"id" => id}, socket) do
    {:ok, _} = Placement.delete_question(%PlacementQuestion{id: id})
    test = Placement.get_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end

  @impl true
  def handle_event("add_option", params, socket) do
    {:ok, _} =
      Placement.create_option(%{
        question_id: params["question_id"],
        text: params["text"],
        is_correct: params["is_correct"] == "true"
      })

    test = Placement.get_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end

  @impl true
  def handle_event("delete_option", %{"id" => id}, socket) do
    {:ok, _} = Placement.delete_option(%PlacementAnswerOption{id: id})
    test = Placement.get_test!(socket.assigns.test.id)
    {:noreply, assign(socket, test: test)}
  end
end
