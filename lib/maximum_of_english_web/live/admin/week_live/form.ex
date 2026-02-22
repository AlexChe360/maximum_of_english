defmodule MaximumOfEnglishWeb.Admin.WeekLive.Form do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Courses
  alias MaximumOfEnglish.Courses.Week

  @impl true
  def mount(params, _session, socket) do
    course = Courses.get_course!(params["course_id"])

    {week, title} =
      case params do
        %{"id" => id} -> {Courses.get_week!(id), "Edit Week"}
        _ -> {%Week{course_id: course.id}, "New Week"}
      end

    changeset = Courses.change_week(week)

    socket =
      socket
      |> assign(page_title: title)
      |> assign(course: course)
      |> assign(week: week)
      |> assign(form: to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>{@page_title} — {@course.title}</.header>

      <div class="card bg-base-200 shadow-sm max-w-xl">
        <div class="card-body">
          <.form for={@form} phx-change="validate" phx-submit="save">
            <.input type="hidden" field={@form[:course_id]} />
            <.input field={@form[:number]} type="number" label="Week Number" required />
            <.input field={@form[:title]} label="Title" required />
            <.input field={@form[:is_unlocked]} type="checkbox" label="Unlocked" />

            <div class="flex gap-2 mt-4">
              <button type="submit" class="btn btn-primary">Save</button>
              <.link navigate={~p"/admin/courses/#{@course.id}/weeks"} class="btn btn-ghost">Cancel</.link>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"week" => params}, socket) do
    changeset = Courses.change_week(socket.assigns.week, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"week" => params}, socket) do
    result =
      if socket.assigns.week.id do
        Courses.update_week(socket.assigns.week, params)
      else
        Courses.create_week(params)
      end

    case result do
      {:ok, _week} ->
        {:noreply,
         socket
         |> put_flash(:info, "Week saved successfully.")
         |> push_navigate(to: ~p"/admin/courses/#{socket.assigns.course.id}/weeks")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end
end
