defmodule MaximumOfEnglishWeb.Admin.StudentLive.Progress do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.{Accounts, Courses, Progress}

  @impl true
  def mount(%{"id" => student_id}, _session, socket) do
    student = Accounts.get_user!(student_id)
    courses = load_courses_with_progress(student.id)

    socket =
      socket
      |> assign(page_title: gettext("Student Progress") <> " — #{student.email}")
      |> assign(student: student)
      |> assign(courses: courses)
      |> assign(generated_password: nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("generate_password", _params, socket) do
    student = socket.assigns.student
    password = Accounts.generate_password()

    case Accounts.set_user_password(student, password) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(generated_password: password)
         |> put_flash(:info, gettext("Password generated for %{email}", email: student.email))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to generate password"))}
    end
  end

  def handle_event("dismiss_password", _params, socket) do
    {:noreply, assign(socket, generated_password: nil)}
  end

  @impl true
  def handle_event("toggle_unlock", %{"week-id" => week_id}, socket) do
    student_id = socket.assigns.student.id

    if Progress.week_unlocked_for_student?(student_id, week_id) do
      Progress.lock_week_for_student(student_id, week_id)
    else
      Progress.unlock_week_for_student(student_id, week_id)
    end

    courses = load_courses_with_progress(student_id)
    {:noreply, assign(socket, courses: courses)}
  end

  defp load_courses_with_progress(student_id) do
    student_unlocks = Progress.student_week_unlock_ids(student_id)

    Courses.list_courses()
    |> Enum.map(fn course ->
      weeks =
        Courses.list_weeks(course.id)
        |> Enum.map(fn week ->
          total = Progress.total_lessons_count(week.id)
          completed = Progress.completed_count(student_id, week.id)
          student_unlocked = MapSet.member?(student_unlocks, week.id)

          %{
            week: week,
            total: total,
            completed: completed,
            student_unlocked: student_unlocked
          }
        end)

      %{course: course, weeks: weeks}
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Student Progress")}
        <:subtitle>{@student.email}</:subtitle>
        <:actions>
          <button
            phx-click="generate_password"
            data-confirm={gettext("Generate a new password? This will replace any existing password.")}
            class="btn btn-sm btn-primary"
          >
            {gettext("Generate Password")}
          </button>
        </:actions>
      </.header>

      <div :if={@generated_password} class="alert alert-success my-4 flex-col sm:flex-row gap-2">
        <div class="min-w-0">
          <p class="font-semibold text-sm">{gettext("Generated password (copy it now, it won't be shown again):")}</p>
          <code class="text-base sm:text-lg select-all bg-base-100 px-3 py-1 rounded break-all">{@generated_password}</code>
        </div>
        <button phx-click="dismiss_password" class="btn btn-sm btn-ghost shrink-0">{gettext("Dismiss")}</button>
      </div>

      <div :for={course_data <- @courses} class="mb-8">
        <h2 class="text-lg font-semibold mb-3">{course_data.course.title}</h2>

        <div class="overflow-x-auto">
          <table class="table table-sm">
            <thead>
              <tr>
                <th>{gettext("Week")}</th>
                <th>{gettext("Progress")}</th>
                <th>{gettext("Global Unlock")}</th>
                <th>{gettext("Student Unlock")}</th>
                <th>{gettext("Action")}</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={wd <- course_data.weeks}>
                <td class="font-medium">{gettext("Week")} {wd.week.number}: {wd.week.title}</td>
                <td>
                  <span class={[
                    "badge badge-sm",
                    wd.completed >= wd.total and wd.total > 0 && "badge-success",
                    (wd.completed < wd.total or wd.total == 0) && "badge-ghost"
                  ]}>
                    {wd.completed}/{wd.total}
                  </span>
                </td>
                <td>
                  <span :if={wd.week.is_unlocked} class="badge badge-sm badge-info">{gettext("Yes")}</span>
                  <span :if={!wd.week.is_unlocked} class="badge badge-sm badge-ghost">{gettext("No")}</span>
                </td>
                <td>
                  <span :if={wd.student_unlocked} class="badge badge-sm badge-success">{gettext("Unlocked")}</span>
                  <span :if={!wd.student_unlocked} class="badge badge-sm badge-ghost">{gettext("Locked")}</span>
                </td>
                <td>
                  <button
                    phx-click="toggle_unlock"
                    phx-value-week-id={wd.week.id}
                    class={[
                      "btn btn-xs",
                      if(wd.student_unlocked, do: "btn-warning", else: "btn-success")
                    ]}
                  >
                    {if wd.student_unlocked, do: gettext("Lock"), else: gettext("Unlock")}
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <.link navigate={~p"/admin/students"} class="btn btn-ghost btn-sm mt-4">
        <.icon name="hero-arrow-left" class="size-4" /> {gettext("Back to Students")}
      </.link>
    </Layouts.app>
    """
  end
end
