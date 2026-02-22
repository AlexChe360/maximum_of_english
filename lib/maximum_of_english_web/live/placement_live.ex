defmodule MaximumOfEnglishWeb.PlacementLive do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.{Accounts, Placement}

  @impl true
  def mount(_params, _session, socket) do
    test = Placement.get_active_test()

    socket =
      socket
      |> assign(page_title: "Placement Test")
      |> assign(test: test)
      |> assign(step: :info)
      |> assign(answers: %{})
      |> assign(current_question: 0)
      |> assign(name: "")
      |> assign(email: "")
      |> assign(phone: "")
      |> assign(result: nil)
      |> assign(form_errors: %{})

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto">
        <%= case @step do %>
          <% :info -> %>
            <div class="card bg-base-200 shadow-lg">
              <div class="card-body">
                <h2 class="card-title text-2xl">Placement Test</h2>
                <%= if @test do %>
                  <p class="text-base-content/70">{@test.description || "Find out your English level by answering a few questions."}</p>
                  <p class="text-sm text-base-content/50">
                    {@test.title} &middot; {length(@test.questions)} questions
                  </p>

                  <div class="divider">Your Information</div>

                  <form phx-change="update_info" phx-submit="start_test" class="space-y-3">
                    <div class="fieldset">
                      <label>
                        <span class="label">Name *</span>
                        <input
                          type="text"
                          class={"w-full input #{if @form_errors[:name], do: "input-error"}"}
                          value={@name}
                          name="name"
                          placeholder="Your name"
                        />
                      </label>
                      <p :if={@form_errors[:name]} class="text-error text-sm mt-1">{@form_errors[:name]}</p>
                    </div>
                    <div class="fieldset">
                      <label>
                        <span class="label">Email *</span>
                        <input
                          type="email"
                          class={"w-full input #{if @form_errors[:email], do: "input-error"}"}
                          value={@email}
                          name="email"
                          placeholder="your@email.com"
                        />
                      </label>
                      <p :if={@form_errors[:email]} class="text-error text-sm mt-1">{@form_errors[:email]}</p>
                    </div>
                    <div class="fieldset">
                      <label>
                        <span class="label">Phone</span>
                        <input
                          type="tel"
                          class="w-full input"
                          value={@phone}
                          name="phone"
                          placeholder="+7 (999) 123-45-67"
                        />
                      </label>
                    </div>

                    <div class="card-actions justify-end mt-4">
                      <button type="submit" class="btn btn-primary">
                        Start Test
                      </button>
                    </div>
                  </form>
                <% else %>
                  <div class="alert alert-warning">
                    <.icon name="hero-exclamation-triangle" class="size-5" />
                    <span>No active placement test available at this time.</span>
                  </div>
                <% end %>
              </div>
            </div>

          <% :testing -> %>
            <% question = Enum.at(@test.questions, @current_question) %>
            <div class="card bg-base-200 shadow-lg">
              <div class="card-body">
                <div class="flex justify-between items-center mb-4">
                  <h2 class="card-title">Question {@current_question + 1} / {length(@test.questions)}</h2>
                  <progress
                    class="progress progress-primary w-32"
                    value={@current_question + 1}
                    max={length(@test.questions)}
                  />
                </div>

                <p class="text-lg font-medium mb-4">{question.text}</p>

                <div class="space-y-2">
                  <%= for option <- question.options do %>
                    <label class={"flex items-center gap-3 p-3 rounded-lg cursor-pointer border-2 transition-colors #{if Map.get(@answers, question.id) == option.id, do: "border-primary bg-primary/10", else: "border-base-300 hover:border-primary/50"}"}>
                      <input
                        type="radio"
                        name={"question_#{question.id}"}
                        class="radio radio-primary"
                        checked={Map.get(@answers, question.id) == option.id}
                        phx-click="select_answer"
                        phx-value-question-id={question.id}
                        phx-value-option-id={option.id}
                      />
                      <span>{option.text}</span>
                    </label>
                  <% end %>
                </div>

                <div class="card-actions justify-between mt-6">
                  <button
                    :if={@current_question > 0}
                    phx-click="prev_question"
                    class="btn btn-ghost"
                  >
                    <.icon name="hero-arrow-left" class="size-4" /> Previous
                  </button>
                  <div :if={@current_question == 0} />

                  <%= if @current_question < length(@test.questions) - 1 do %>
                    <button phx-click="next_question" class="btn btn-primary">
                      Next <.icon name="hero-arrow-right" class="size-4" />
                    </button>
                  <% else %>
                    <button phx-click="submit_test" class="btn btn-success">
                      Submit Test
                    </button>
                  <% end %>
                </div>
              </div>
            </div>

          <% :result -> %>
            <div class="card bg-base-200 shadow-lg">
              <div class="card-body text-center">
                <h2 class="text-3xl font-bold mb-2">Your Result</h2>

                <div class="stats shadow bg-base-100 my-6">
                  <div class="stat">
                    <div class="stat-title">Score</div>
                    <div class="stat-value text-primary">{@result.score} / {@result.total}</div>
                    <div class="stat-desc">{round(@result.score / max(@result.total, 1) * 100)}%</div>
                  </div>
                  <div class="stat">
                    <div class="stat-title">Level</div>
                    <div class="stat-value text-secondary">{@result.level}</div>
                    <div class="stat-desc">English proficiency</div>
                  </div>
                </div>

                <p class="text-base-content/70 mb-6">
                  Thank you, {@name}! Your results have been saved. Our team will contact you
                  to assign you to the appropriate course.
                </p>

                <div class="card-actions justify-center">
                  <.link navigate={~p"/"} class="btn btn-primary">Back to Home</.link>
                </div>
              </div>
            </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("update_info", params, socket) do
    {:noreply,
     socket
     |> assign(name: params["name"] || "", email: params["email"] || "", phone: params["phone"] || "")
     |> assign(form_errors: %{})}
  end

  @impl true
  def handle_event("start_test", params, socket) do
    name = String.trim(params["name"] || socket.assigns.name)
    email = String.trim(params["email"] || socket.assigns.email)
    phone = params["phone"] || socket.assigns.phone

    errors = %{}
    errors = if name == "", do: Map.put(errors, :name, "Name is required"), else: errors
    errors = if email == "", do: Map.put(errors, :email, "Email is required"), else: errors

    if errors == %{} do
      {:noreply, assign(socket, name: name, email: email, phone: phone, step: :testing, form_errors: %{})}
    else
      {:noreply, assign(socket, name: name, email: email, phone: phone, form_errors: errors)}
    end
  end

  @impl true
  def handle_event("select_answer", %{"question-id" => q_id, "option-id" => o_id}, socket) do
    answers = Map.put(socket.assigns.answers, q_id, o_id)
    {:noreply, assign(socket, answers: answers)}
  end

  @impl true
  def handle_event("next_question", _params, socket) do
    {:noreply, assign(socket, current_question: socket.assigns.current_question + 1)}
  end

  @impl true
  def handle_event("prev_question", _params, socket) do
    {:noreply, assign(socket, current_question: max(socket.assigns.current_question - 1, 0))}
  end

  @impl true
  def handle_event("submit_test", _params, socket) do
    %{test: test, answers: answers, name: name, email: email, phone: phone} = socket.assigns

    {score, total, level} = Placement.grade_placement(test.id, answers)

    {:ok, _result} =
      Placement.create_result(%{
        name: name,
        email: email,
        phone: phone,
        score: score,
        level: level,
        answers: answers
      })

    Accounts.ensure_student_account(email)

    result = %{score: score, total: total, level: level}
    {:noreply, assign(socket, step: :result, result: result)}
  end
end
