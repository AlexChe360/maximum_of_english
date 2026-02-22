defmodule MaximumOfEnglishWeb.Admin.CourseLive.Form do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Courses
  alias MaximumOfEnglish.Courses.Course

  @impl true
  def mount(params, _session, socket) do
    {course, title} =
      case params do
        %{"id" => id} -> {Courses.get_course!(id), "Edit Course"}
        _ -> {%Course{}, "New Course"}
      end

    changeset = Courses.change_course(course)

    socket =
      socket
      |> assign(page_title: title)
      |> assign(course: course)
      |> assign(form: to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <div class="card bg-base-200 shadow-sm max-w-xl">
        <div class="card-body">
          <.form for={@form} phx-change="validate" phx-submit="save">
            <.input field={@form[:title]} label="Title" required />
            <.input field={@form[:description]} type="textarea" label="Description" />
            <.input field={@form[:is_active]} type="checkbox" label="Active" />

            <div class="flex gap-2 mt-4">
              <button type="submit" class="btn btn-primary">Save</button>
              <.link navigate={~p"/admin/courses"} class="btn btn-ghost">Cancel</.link>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"course" => params}, socket) do
    changeset = Courses.change_course(socket.assigns.course, params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"course" => params}, socket) do
    result =
      if socket.assigns.course.id do
        Courses.update_course(socket.assigns.course, params)
      else
        Courses.create_course(params)
      end

    case result do
      {:ok, _course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Course saved successfully.")
         |> push_navigate(to: ~p"/admin/courses")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end
end
