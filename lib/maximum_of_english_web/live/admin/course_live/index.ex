defmodule MaximumOfEnglishWeb.Admin.CourseLive.Index do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Courses

  @impl true
  def mount(_params, _session, socket) do
    courses = Courses.list_courses()

    socket =
      socket
      |> assign(page_title: "Courses")
      |> assign(courses: courses)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Courses
        <:actions>
          <.link navigate={~p"/admin/courses/new"} class="btn btn-primary btn-sm">
            <.icon name="hero-plus" class="size-4" /> New Course
          </.link>
        </:actions>
      </.header>

      <.table id="courses" rows={@courses}>
        <:col :let={course} label="Title">{course.title}</:col>
        <:col :let={course} label="Active">
          <span class={"badge #{if course.is_active, do: "badge-success", else: "badge-error"}"}>
            {if course.is_active, do: "Yes", else: "No"}
          </span>
        </:col>
        <:action :let={course}>
          <.link navigate={~p"/admin/courses/#{course.id}/edit"} class="link link-primary text-sm">Edit</.link>
        </:action>
        <:action :let={course}>
          <.link navigate={~p"/admin/courses/#{course.id}/weeks"} class="link link-secondary text-sm">Weeks</.link>
        </:action>
        <:action :let={course}>
          <.link phx-click="delete" phx-value-id={course.id} data-confirm="Are you sure?" class="link link-error text-sm">
            Delete
          </.link>
        </:action>
      </.table>

      <.link navigate={~p"/admin"} class="btn btn-ghost btn-sm mt-4">
        <.icon name="hero-arrow-left" class="size-4" /> Back
      </.link>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Courses.get_course!(id)
    {:ok, _} = Courses.delete_course(course)
    {:noreply, assign(socket, courses: Courses.list_courses())}
  end
end
