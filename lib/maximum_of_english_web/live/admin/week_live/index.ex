defmodule MaximumOfEnglishWeb.Admin.WeekLive.Index do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Courses

  @impl true
  def mount(%{"course_id" => course_id}, _session, socket) do
    course = Courses.get_course!(course_id)
    weeks = Courses.list_weeks(course_id)

    socket =
      socket
      |> assign(page_title: "Weeks — #{course.title}")
      |> assign(course: course)
      |> assign(weeks: weeks)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Weeks — {@course.title}
        <:actions>
          <.link navigate={~p"/admin/courses/#{@course.id}/weeks/new"} class="btn btn-primary btn-sm">
            <.icon name="hero-plus" class="size-4" /> New Week
          </.link>
        </:actions>
      </.header>

      <.table id="weeks" rows={@weeks}>
        <:col :let={week} label="Number">{week.number}</:col>
        <:col :let={week} label="Title">{week.title}</:col>
        <:col :let={week} label="Unlocked">
          <button phx-click="toggle_unlock" phx-value-id={week.id} class="cursor-pointer">
            <span class={"badge #{if week.is_unlocked, do: "badge-success", else: "badge-error"}"}>
              {if week.is_unlocked, do: "Unlocked", else: "Locked"}
            </span>
          </button>
        </:col>
        <:action :let={week}>
          <.link navigate={~p"/admin/courses/#{@course.id}/weeks/#{week.id}/edit"} class="link link-primary text-sm">Edit</.link>
        </:action>
        <:action :let={week}>
          <.link navigate={~p"/admin/weeks/#{week.id}/lessons"} class="link link-secondary text-sm">Lessons</.link>
        </:action>
        <:action :let={week}>
          <.link phx-click="delete" phx-value-id={week.id} data-confirm="Are you sure?" class="link link-error text-sm">
            Delete
          </.link>
        </:action>
      </.table>

      <.link navigate={~p"/admin/courses"} class="btn btn-ghost btn-sm mt-4">
        <.icon name="hero-arrow-left" class="size-4" /> Back to Courses
      </.link>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("toggle_unlock", %{"id" => id}, socket) do
    week = Courses.get_week!(id)
    {:ok, _} = Courses.toggle_week_unlock(week)
    weeks = Courses.list_weeks(socket.assigns.course.id)
    {:noreply, assign(socket, weeks: weeks)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    week = Courses.get_week!(id)
    {:ok, _} = Courses.delete_week(week)
    weeks = Courses.list_weeks(socket.assigns.course.id)
    {:noreply, assign(socket, weeks: weeks)}
  end
end
