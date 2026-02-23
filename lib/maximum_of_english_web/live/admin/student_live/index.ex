defmodule MaximumOfEnglishWeb.Admin.StudentLive.Index do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Accounts

  @impl true
  def mount(_params, _session, socket) do
    students = Accounts.list_students()

    socket =
      socket
      |> assign(page_title: gettext("Students"))
      |> assign(students: students)
      |> assign(generated_password: nil)
      |> assign(generated_for: nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("generate_password", %{"id" => student_id}, socket) do
    student = Accounts.get_user!(student_id)
    password = Accounts.generate_password()

    case Accounts.set_user_password(student, password) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(generated_password: password, generated_for: student_id)
         |> put_flash(:info, gettext("Password generated for %{email}", email: student.email))}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to generate password"))}
    end
  end

  def handle_event("dismiss_password", _params, socket) do
    {:noreply, assign(socket, generated_password: nil, generated_for: nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Students")}
        <:subtitle>{length(@students)} {gettext("registered students")}</:subtitle>
      </.header>

      <div :if={@generated_password} class="alert alert-success my-4 flex-col sm:flex-row gap-2">
        <div class="min-w-0">
          <p class="font-semibold text-sm">{gettext("Generated password (copy it now, it won't be shown again):")}</p>
          <code class="text-base sm:text-lg select-all bg-base-100 px-3 py-1 rounded break-all">{@generated_password}</code>
        </div>
        <button phx-click="dismiss_password" class="btn btn-sm btn-ghost shrink-0">{gettext("Dismiss")}</button>
      </div>

      <.table id="students" rows={@students}>
        <:col :let={student} label={gettext("Email")}>{student.email}</:col>
        <:col :let={student} label={gettext("Has Password")}>
          <span :if={student.hashed_password} class="badge badge-sm badge-success">{gettext("Yes")}</span>
          <span :if={!student.hashed_password} class="badge badge-sm badge-warning">{gettext("No")}</span>
        </:col>
        <:col :let={student} label={gettext("Registered")}>{Calendar.strftime(student.inserted_at, "%Y-%m-%d")}</:col>
        <:action :let={student}>
          <button
            phx-click="generate_password"
            phx-value-id={student.id}
            data-confirm={gettext("Generate a new password? This will replace any existing password.")}
            class="btn btn-xs btn-primary"
          >
            {gettext("Generate Password")}
          </button>
        </:action>
        <:action :let={student}>
          <.link navigate={~p"/admin/students/#{student.id}/progress"} class="link link-primary text-sm">
            {gettext("Progress")}
          </.link>
        </:action>
      </.table>

      <.link navigate={~p"/admin"} class="btn btn-ghost btn-sm mt-4">
        <.icon name="hero-arrow-left" class="size-4" /> {gettext("Back to Dashboard")}
      </.link>
    </Layouts.app>
    """
  end
end
