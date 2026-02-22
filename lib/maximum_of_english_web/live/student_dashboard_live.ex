defmodule MaximumOfEnglishWeb.StudentDashboardLive do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.{Courses, Progress, Tests}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    courses = Courses.list_active_courses()

    socket =
      socket
      |> assign(page_title: "Dashboard")
      |> assign(courses: courses)
      |> assign(selected_course: List.first(courses))
      |> assign(weeks: [])
      |> assign(selected_week: nil)
      |> assign(active_tab: "grammar")
      |> assign(selected_lesson: nil)
      |> assign(completed_ids: MapSet.new())
      |> assign(test_answers: %{})
      |> assign(test_result: nil)
      |> assign(student_id: user.id)
      |> assign(student_unlocked_ids: MapSet.new())

    socket =
      if socket.assigns.selected_course do
        load_course_data(socket, socket.assigns.selected_course.id)
      else
        socket
      end

    {:ok, socket}
  end

  defp load_course_data(socket, course_id) do
    weeks = Courses.list_weeks_with_lessons(course_id)
    student_id = socket.assigns.student_id
    student_unlocked_ids = Progress.student_week_unlock_ids(student_id)

    first_accessible =
      Enum.find(weeks, fn w -> w.is_unlocked or MapSet.member?(student_unlocked_ids, w.id) end) ||
        List.first(weeks)

    socket
    |> assign(weeks: weeks)
    |> assign(student_unlocked_ids: student_unlocked_ids)
    |> assign(selected_week: first_accessible)
    |> load_week_data(first_accessible)
  end

  defp load_week_data(socket, nil), do: socket

  defp load_week_data(socket, week) do
    completed_ids = Progress.completed_lesson_ids(socket.assigns.student_id, week.id)

    socket
    |> assign(selected_week: week)
    |> assign(completed_ids: completed_ids)
    |> assign(selected_lesson: nil)
    |> assign(test_answers: %{})
    |> assign(test_result: nil)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex gap-6">
        <%!-- Left sidebar: Weeks --%>
        <aside class="w-64 shrink-0">
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body p-4">
              <h2 class="card-title text-lg">
                <.icon name="hero-calendar-days" class="size-5" />
                Weeks
              </h2>
              <ul class="menu menu-sm">
                <%= for week <- @weeks do %>
                  <li>
                    <button
                      phx-click="select_week"
                      phx-value-id={week.id}
                      class={"#{if @selected_week && @selected_week.id == week.id, do: "active"}"}
                    >
                      <span class="flex items-center gap-2">
                        <%= if week.is_unlocked or MapSet.member?(@student_unlocked_ids, week.id) do %>
                          <.icon name="hero-lock-open" class="size-4 text-success" />
                        <% else %>
                          <.icon name="hero-lock-closed" class="size-4 text-error" />
                        <% end %>
                        Week {week.number}: {week.title}
                      </span>
                    </button>
                  </li>
                <% end %>
              </ul>
            </div>
          </div>

          <%!-- Progress --%>
          <div :if={@selected_week} class="card bg-base-200 shadow-sm mt-4">
            <div class="card-body p-4">
              <h3 class="font-semibold text-sm">Progress</h3>
              <% total = length(@selected_week.lessons) %>
              <% done = MapSet.size(@completed_ids) %>
              <progress
                class="progress progress-success w-full"
                value={done}
                max={max(total, 1)}
              />
              <span class="text-xs text-base-content/60">{done}/{total} lessons completed</span>
            </div>
          </div>
        </aside>

        <%!-- Main content --%>
        <div class="flex-1">
          <%= if @selected_week do %>
            <%= if @selected_week.is_unlocked or MapSet.member?(@student_unlocked_ids, @selected_week.id) do %>
              <%!-- Tabs --%>
              <div role="tablist" class="tabs tabs-box mb-6">
                <button
                  role="tab"
                  class={"tab #{if @active_tab == "grammar", do: "tab-active"}"}
                  phx-click="set_tab"
                  phx-value-tab="grammar"
                >
                  <.icon name="hero-academic-cap" class="size-4 mr-1" /> Grammar
                </button>
                <button
                  role="tab"
                  class={"tab #{if @active_tab == "reading", do: "tab-active"}"}
                  phx-click="set_tab"
                  phx-value-tab="reading"
                >
                  <.icon name="hero-document-text" class="size-4 mr-1" /> Reading
                </button>
                <button
                  role="tab"
                  class={"tab #{if @active_tab == "listening", do: "tab-active"}"}
                  phx-click="set_tab"
                  phx-value-tab="listening"
                >
                  <.icon name="hero-speaker-wave" class="size-4 mr-1" /> Listening
                </button>
              </div>

              <%!-- Lesson pills --%>
              <div class="flex flex-wrap gap-2 mb-6">
                <%= for lesson <- lessons_for_tab(@selected_week, @active_tab) do %>
                  <% accessible = lesson_accessible?(@student_id, lesson, @selected_week) %>
                  <% completed = MapSet.member?(@completed_ids, lesson.id) %>
                  <button
                    phx-click={if accessible, do: "select_lesson"}
                    phx-value-id={if accessible, do: lesson.id}
                    disabled={!accessible}
                    class={"btn btn-sm #{cond do
                      completed -> "btn-success"
                      @selected_lesson && @selected_lesson.id == lesson.id -> "btn-primary"
                      accessible -> "btn-outline"
                      true -> "btn-disabled opacity-50"
                    end}"}
                  >
                    <%= if completed do %>
                      <.icon name="hero-check-circle" class="size-4" />
                    <% end %>
                    <%= if not accessible do %>
                      <.icon name="hero-lock-closed" class="size-4" />
                    <% end %>
                    {lesson.title}
                  </button>
                <% end %>
              </div>

              <%!-- Lesson content --%>
              <%= if @selected_lesson do %>
                <div class="card bg-base-200 shadow-sm">
                  <div class="card-body">
                    <h3 class="card-title">
                      <.icon name={kind_icon(@selected_lesson.kind)} class="size-5 text-primary" />
                      {String.capitalize(@selected_lesson.kind)}: {@selected_lesson.title}
                      <span :if={MapSet.member?(@completed_ids, @selected_lesson.id)} class="badge badge-success badge-sm">
                        Completed
                      </span>
                    </h3>

                    <%!-- Grammar: video + file --%>
                    <div :if={@selected_lesson.kind == "grammar"}>
                      <div :if={@selected_lesson.video_url} class="my-4">
                        <video controls class="w-full rounded-lg">
                          <source src={@selected_lesson.video_url} />
                          Your browser does not support video.
                        </video>
                      </div>
                      <a :if={@selected_lesson.file_url} href={@selected_lesson.file_url} target="_blank" class="btn btn-outline btn-sm mt-2">
                        <.icon name="hero-arrow-down-tray" class="size-4" /> Download Materials
                      </a>
                    </div>

                    <%!-- Reading: description + vocabulary --%>
                    <div :if={@selected_lesson.kind == "reading"}>
                      <div :if={@selected_lesson.description} class="prose max-w-none my-4">
                        {Phoenix.HTML.raw(@selected_lesson.description)}
                      </div>
                      <div :if={@selected_lesson.vocabulary} class="mt-4">
                        <h4 class="font-semibold text-sm mb-2">Vocabulary</h4>
                        <div class="bg-base-100 p-4 rounded-lg text-sm whitespace-pre-wrap">{@selected_lesson.vocabulary}</div>
                      </div>
                    </div>

                    <%!-- Listening: audio --%>
                    <div :if={@selected_lesson.kind == "listening"}>
                      <div :if={@selected_lesson.description} class="prose max-w-none my-4">
                        {Phoenix.HTML.raw(@selected_lesson.description)}
                      </div>
                      <div :if={@selected_lesson.audio_url} class="my-4">
                        <audio controls class="w-full">
                          <source src={@selected_lesson.audio_url} />
                          Your browser does not support audio.
                        </audio>
                      </div>
                    </div>

                    <%!-- Image for any type --%>
                    <img :if={@selected_lesson.image_url} src={@selected_lesson.image_url} class="rounded-lg mt-4 max-w-full" />
                  </div>
                </div>

                <%!-- Test section --%>
                <.lesson_test_section
                  lesson={@selected_lesson}
                  test_answers={@test_answers}
                  test_result={@test_result}
                  completed={MapSet.member?(@completed_ids, @selected_lesson.id)}
                />
              <% else %>
                <div class="card bg-base-200 shadow-sm">
                  <div class="card-body text-center text-base-content/50">
                    <.icon name="hero-cursor-arrow-rays" class="size-8 mx-auto mb-2" />
                    <p>Select a lesson to start learning</p>
                  </div>
                </div>
              <% end %>
            <% else %>
              <div class="alert alert-warning">
                <.icon name="hero-lock-closed" class="size-5" />
                <div>
                  <h3 class="font-bold">Week Locked</h3>
                  <p>This week is not yet unlocked. Please wait for your curator to unlock it.</p>
                </div>
              </div>
            <% end %>
          <% else %>
            <div class="card bg-base-200 shadow-sm">
              <div class="card-body text-center">
                <p class="text-base-content/50">No courses available yet. Please contact your curator.</p>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".SortableMatching">
      export default {
        mounted() {
          this.sortable = new Sortable(this.el, {
            animation: 150,
            ghostClass: "sortable-ghost",
            chosenClass: "sortable-chosen",
            onEnd: () => {
              const items = [...this.el.children].map(el => el.dataset.value);
              this.pushEvent("matching_reorder", {
                question_id: this.el.dataset.questionId,
                order: items
              });
            }
          });
        },
        destroyed() {
          if (this.sortable) this.sortable.destroy();
        }
      }
    </script>
    """
  end

  defp lesson_test_section(assigns) do
    ~H"""
    <% test = get_test(@lesson.id) %>
    <%= if test do %>
      <div class="card bg-base-200 shadow-sm mt-4">
        <div class="card-body">
          <h4 class="card-title text-lg">
            <.icon name="hero-clipboard-document-check" class="size-5" />
            Lesson Test
          </h4>

          <%= if @completed do %>
            <div class="alert alert-success">
              <.icon name="hero-check-circle" class="size-5" />
              <span>You have already completed this lesson. Well done!</span>
            </div>
          <% else %>
            <%= if @test_result do %>
              <div class={"alert #{if @test_result.passed, do: "alert-success", else: "alert-error"}"}>
                <.icon name={if @test_result.passed, do: "hero-check-circle", else: "hero-x-circle"} class="size-5" />
                <div>
                  <p class="font-semibold">Score: {@test_result.correct}/{@test_result.total}</p>
                  <p :if={@test_result.passed}>Congratulations! Lesson marked as completed.</p>
                  <p :if={!@test_result.passed}>You need at least 70% to pass. Try again!</p>
                </div>
              </div>
              <button :if={!@test_result.passed} phx-click="retry_test" class="btn btn-outline btn-sm mt-2">
                Retry Test
              </button>
            <% else %>
              <div class="space-y-4">
                <%= for question <- test.questions do %>
                  <div class="border border-base-300 rounded-lg p-4">
                    <p class="font-medium mb-3">
                      {question.position}. {question.text}
                      <span :if={question.question_type == "matching"} class="badge badge-info badge-sm ml-1">Matching</span>
                    </p>

                    <%= if question.question_type == "matching" do %>
                      <.matching_question question={question} test_answers={@test_answers} />
                    <% else %>
                      <div class="space-y-2">
                        <%= for option <- question.options do %>
                          <label class={"flex items-center gap-3 p-2 rounded cursor-pointer hover:bg-base-300 #{if Map.get(@test_answers, question.id) == option.id, do: "bg-primary/10"}"}>
                            <input
                              type="radio"
                              name={"test_q_#{question.id}"}
                              class="radio radio-primary radio-sm"
                              checked={Map.get(@test_answers, question.id) == option.id}
                              phx-click="test_select"
                              phx-value-question-id={question.id}
                              phx-value-option-id={option.id}
                            />
                            <span class="text-sm">{option.text}</span>
                          </label>
                        <% end %>
                      </div>
                    <% end %>
                  </div>
                <% end %>
              </div>

              <div class="card-actions justify-end mt-4">
                <button phx-click="submit_lesson_test" phx-value-test-id={test.id} class="btn btn-primary">
                  Submit Answers
                </button>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    <% else %>
      <%!-- No test - mark complete manually --%>
      <div :if={!@completed} class="mt-4">
        <button phx-click="mark_complete" phx-value-lesson-id={@lesson.id} class="btn btn-success">
          <.icon name="hero-check" class="size-4" /> Mark as Complete
        </button>
      </div>
    <% end %>
    """
  end

  defp matching_question(assigns) do
    # Get the current order from test_answers, or use original order as fallback
    current_order = Map.get(assigns.test_answers, assigns.question.id, [])

    match_texts =
      if current_order == [] do
        Enum.map(assigns.question.options, & &1.match_text)
      else
        current_order
      end

    assigns = assign(assigns, :match_texts, match_texts)

    ~H"""
    <div class="grid grid-cols-2 gap-4">
      <%!-- Left column: fixed items --%>
      <div class="space-y-2">
        <p class="text-xs font-semibold text-base-content/60 mb-1">Items</p>
        <%= for option <- @question.options do %>
          <div class="bg-base-100 border border-base-300 rounded-lg p-3 text-sm">
            {option.text}
          </div>
        <% end %>
      </div>

      <%!-- Right column: draggable match texts --%>
      <div>
        <p class="text-xs font-semibold text-base-content/60 mb-1">Drag to match</p>
        <div
          id={"sortable-#{@question.id}"}
          phx-hook=".SortableMatching"
          phx-update="ignore"
          data-question-id={@question.id}
          class="space-y-2"
        >
          <%= for match_text <- @match_texts do %>
            <div
              data-value={match_text}
              class="bg-primary/10 border border-primary/30 rounded-lg p-3 text-sm cursor-grab active:cursor-grabbing select-none"
            >
              {match_text}
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp get_test(lesson_id) do
    Tests.get_test_for_lesson(lesson_id)
  end

  defp lessons_for_tab(week, tab) do
    Enum.filter(week.lessons, &(&1.kind == tab))
  end

  defp lesson_accessible?(student_id, lesson, week) do
    Progress.lesson_accessible?(student_id, lesson, week)
  end

  defp kind_icon("grammar"), do: "hero-academic-cap"
  defp kind_icon("reading"), do: "hero-document-text"
  defp kind_icon("listening"), do: "hero-speaker-wave"
  defp kind_icon(_), do: "hero-question-mark-circle"

  defp init_matching_answers(lesson_id) do
    case Tests.get_test_for_lesson(lesson_id) do
      nil ->
        %{}

      test ->
        test.questions
        |> Enum.filter(&(&1.question_type == "matching"))
        |> Enum.reduce(%{}, fn question, acc ->
          shuffled =
            question.options
            |> Enum.map(& &1.match_text)
            |> Enum.shuffle()

          Map.put(acc, question.id, shuffled)
        end)
    end
  end

  # Event handlers

  @impl true
  def handle_event("select_week", %{"id" => id}, socket) do
    week = Enum.find(socket.assigns.weeks, &(&1.id == id))
    {:noreply, load_week_data(socket, week)}
  end

  @impl true
  def handle_event("set_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, active_tab: tab, selected_lesson: nil, test_answers: %{}, test_result: nil)}
  end

  @impl true
  def handle_event("select_lesson", %{"id" => id}, socket) do
    lesson = Courses.get_lesson_with_test!(id)

    # Pre-shuffle matching question answers
    test_answers = init_matching_answers(lesson.id)

    {:noreply, assign(socket, selected_lesson: lesson, test_answers: test_answers, test_result: nil)}
  end

  @impl true
  def handle_event("test_select", %{"question-id" => q_id, "option-id" => o_id}, socket) do
    answers = Map.put(socket.assigns.test_answers, q_id, o_id)
    {:noreply, assign(socket, test_answers: answers)}
  end

  @impl true
  def handle_event("matching_reorder", %{"question_id" => q_id, "order" => order}, socket) do
    answers = Map.put(socket.assigns.test_answers, q_id, order)
    {:noreply, assign(socket, test_answers: answers)}
  end

  @impl true
  def handle_event("submit_lesson_test", %{"test-id" => test_id}, socket) do
    %{test_answers: answers, student_id: student_id, selected_lesson: lesson} = socket.assigns

    {correct, total, passed} = Tests.grade_test(test_id, answers)

    socket =
      if passed do
        Progress.complete_lesson(student_id, lesson.id)
        Progress.maybe_auto_unlock_next_week(student_id, lesson)

        completed_ids = MapSet.put(socket.assigns.completed_ids, lesson.id)
        student_unlocked_ids = Progress.student_week_unlock_ids(student_id)

        socket
        |> assign(completed_ids: completed_ids)
        |> assign(student_unlocked_ids: student_unlocked_ids)
        |> assign(test_result: %{correct: correct, total: total, passed: true})
      else
        assign(socket, test_result: %{correct: correct, total: total, passed: false})
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("retry_test", _params, socket) do
    test_answers = init_matching_answers(socket.assigns.selected_lesson.id)
    {:noreply, assign(socket, test_answers: test_answers, test_result: nil)}
  end

  @impl true
  def handle_event("mark_complete", %{"lesson-id" => lesson_id}, socket) do
    student_id = socket.assigns.student_id
    lesson = Courses.get_lesson!(lesson_id)

    Progress.complete_lesson(student_id, lesson_id)
    Progress.maybe_auto_unlock_next_week(student_id, lesson)

    completed_ids = MapSet.put(socket.assigns.completed_ids, lesson_id)
    student_unlocked_ids = Progress.student_week_unlock_ids(student_id)

    {:noreply, assign(socket, completed_ids: completed_ids, student_unlocked_ids: student_unlocked_ids)}
  end
end
