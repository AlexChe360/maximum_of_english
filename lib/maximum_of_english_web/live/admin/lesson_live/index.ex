defmodule MaximumOfEnglishWeb.Admin.LessonLive.Index do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Courses

  @impl true
  def mount(%{"week_id" => week_id}, _session, socket) do
    week = Courses.get_week!(week_id)
    course = Courses.get_course!(week.course_id)
    lessons = Courses.list_lessons(week_id)

    socket =
      socket
      |> assign(page_title: "Lessons — Week #{week.number}")
      |> assign(week: week)
      |> assign(course: course)
      |> assign(lessons: lessons)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Lessons — Week {@week.number}: {@week.title}
        <:actions>
          <.link navigate={~p"/admin/weeks/#{@week.id}/lessons/new"} class="btn btn-primary btn-sm">
            <.icon name="hero-plus" class="size-4" /> New Lesson
          </.link>
        </:actions>
      </.header>

      <.table id="lessons" rows={@lessons}>
        <:col :let={lesson} label="Kind">
          <span class={"badge #{kind_badge(lesson.kind)}"}>
            {String.capitalize(lesson.kind)}
          </span>
        </:col>
        <:col :let={lesson} label="Position">{lesson.position}</:col>
        <:col :let={lesson} label="Title">{lesson.title}</:col>
        <:action :let={lesson}>
          <.link navigate={~p"/admin/weeks/#{@week.id}/lessons/#{lesson.id}/edit"} class="link link-primary text-sm">Edit</.link>
        </:action>
        <:action :let={lesson}>
          <.link navigate={~p"/admin/lessons/#{lesson.id}/test"} class="link link-secondary text-sm">Test</.link>
        </:action>
        <:action :let={lesson}>
          <.link phx-click="delete" phx-value-id={lesson.id} data-confirm="Are you sure?" class="link link-error text-sm">
            Delete
          </.link>
        </:action>
      </.table>

      <.link navigate={~p"/admin/courses/#{@course.id}/weeks"} class="btn btn-ghost btn-sm mt-4">
        <.icon name="hero-arrow-left" class="size-4" /> Back to Weeks
      </.link>
    </Layouts.app>
    """
  end

  defp kind_badge("grammar"), do: "badge-primary"
  defp kind_badge("reading"), do: "badge-secondary"
  defp kind_badge("listening"), do: "badge-accent"
  defp kind_badge(_), do: "badge-ghost"

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lesson = Courses.get_lesson!(id)
    {:ok, _} = Courses.delete_lesson(lesson)
    lessons = Courses.list_lessons(socket.assigns.week.id)
    {:noreply, assign(socket, lessons: lessons)}
  end
end
