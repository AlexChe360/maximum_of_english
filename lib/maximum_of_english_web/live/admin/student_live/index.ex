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
      |> assign(show_add_form: false)

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_add_form", _params, socket) do
    {:noreply, assign(socket, show_add_form: !socket.assigns.show_add_form)}
  end

  @impl true
  def handle_event("add_student", %{"email" => email, "password" => password, "name" => name, "level" => level}, socket) do
    password = if password == "", do: Accounts.generate_password(), else: password
    attrs = %{name: name, level: if(level == "", do: nil, else: level)}

    case Accounts.ensure_student_account(email, attrs) do
      {:ok, student} ->
        case Accounts.set_user_password(student, password) do
          {:ok, _} ->
            {:noreply,
             socket
             |> assign(
               students: Accounts.list_students(),
               show_add_form: false,
               generated_password: password,
               generated_for: student.id
             )
             |> put_flash(:info, gettext("Student %{email} created", email: email))}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, gettext("Failed to set password"))}
        end

      {:error, changeset} ->
        message =
          changeset
          |> Ecto.Changeset.traverse_errors(fn {msg, _opts} -> msg end)
          |> Enum.map_join(", ", fn {field, msgs} -> "#{field}: #{Enum.join(msgs, ", ")}" end)

        {:noreply, put_flash(socket, :error, message)}
    end
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
  def handle_event("delete_student", %{"id" => id}, socket) do
    student = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(student)

    {:noreply,
     socket
     |> assign(students: Accounts.list_students())
     |> put_flash(:info, gettext("Student %{email} deleted", email: student.email))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Students")}
        <:subtitle>{length(@students)} {gettext("registered students")}</:subtitle>
        <:actions>
          <button phx-click="toggle_add_form" class="btn btn-primary btn-sm">
            <.icon name="hero-plus" class="size-4" /> {gettext("Add Student")}
          </button>
        </:actions>
      </.header>

      <div :if={@show_add_form} class="card bg-base-200 shadow-sm my-4">
        <div class="card-body">
          <h3 class="card-title text-base">{gettext("Add Student")}</h3>
          <form phx-submit="add_student" class="flex flex-col sm:flex-row items-end gap-3">
            <div class="flex-1 w-full">
              <label class="label text-sm">{gettext("Name")}</label>
              <input type="text" name="name" placeholder={gettext("Student name")} class="input w-full" required />
            </div>
            <div class="flex-1 w-full">
              <label class="label text-sm">{gettext("Email")}</label>
              <input type="email" name="email" placeholder="student@example.com" class="input w-full" required />
            </div>
            <div class="flex-1 w-full">
              <label class="label text-sm">{gettext("Level")}</label>
              <select name="level" class="select w-full">
                <option value="">—</option>
                <option value="Beginner">Beginner</option>
                <option value="Elementary">Elementary</option>
                <option value="Pre-Intermediate">Pre-Intermediate</option>
                <option value="Intermediate">Intermediate</option>
                <option value="Upper-Intermediate">Upper-Intermediate</option>
                <option value="Advanced">Advanced</option>
              </select>
            </div>
            <div class="flex-1 w-full">
              <label class="label text-sm">{gettext("Password")}</label>
              <input type="text" name="password" placeholder={gettext("Leave empty to auto-generate")} class="input w-full" />
            </div>
            <div class="flex gap-2">
              <button type="submit" class="btn btn-primary btn-sm">{gettext("Create")}</button>
              <button type="button" phx-click="toggle_add_form" class="btn btn-ghost btn-sm">{gettext("Cancel")}</button>
            </div>
          </form>
        </div>
      </div>

      <div :if={@generated_password} class="alert alert-success my-4 flex-col sm:flex-row gap-2">
        <div class="min-w-0">
          <p class="font-semibold text-sm">{gettext("Generated password (copy it now, it won't be shown again):")}</p>
          <code class="text-base sm:text-lg select-all bg-base-100 px-3 py-1 rounded break-all">{@generated_password}</code>
        </div>
        <button phx-click="dismiss_password" class="btn btn-sm btn-ghost shrink-0">{gettext("Dismiss")}</button>
      </div>

      <.table id="students" rows={@students}>
        <:col :let={student} label={gettext("Name")}>{student.name}</:col>
        <:col :let={student} label={gettext("Email")}>{student.email}</:col>
        <:col :let={student} label={gettext("Level")}>
          <span :if={student.level} class="badge badge-sm badge-info">{student.level}</span>
        </:col>
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
        <:action :let={student}>
          <.link phx-click="delete_student" phx-value-id={student.id} data-confirm={gettext("Delete this student? This cannot be undone.")} class="link link-error text-sm">
            {gettext("Delete")}
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
