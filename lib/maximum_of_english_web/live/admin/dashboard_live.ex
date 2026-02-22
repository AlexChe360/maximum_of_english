defmodule MaximumOfEnglishWeb.Admin.DashboardLive do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.{Accounts, Courses, Placement}

  @impl true
  def mount(_params, _session, socket) do
    courses = Courses.list_courses()
    results = Placement.list_results()
    students_count = Accounts.students_count()

    socket =
      socket
      |> assign(page_title: "Admin Dashboard")
      |> assign(courses_count: length(courses))
      |> assign(results_count: length(results))
      |> assign(students_count: students_count)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Admin Dashboard
        <:subtitle>Manage your courses, lessons, and tests.</:subtitle>
      </.header>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="stat bg-base-200 rounded-box shadow-sm">
          <div class="stat-title">Courses</div>
          <div class="stat-value text-primary">{@courses_count}</div>
          <div class="stat-actions">
            <.link navigate={~p"/admin/courses"} class="btn btn-sm btn-primary">Manage</.link>
          </div>
        </div>
        <div class="stat bg-base-200 rounded-box shadow-sm">
          <div class="stat-title">Placement Results</div>
          <div class="stat-value text-secondary">{@results_count}</div>
          <div class="stat-actions">
            <.link navigate={~p"/admin/placement-results"} class="btn btn-sm btn-secondary">View</.link>
          </div>
        </div>
        <div class="stat bg-base-200 rounded-box shadow-sm">
          <div class="stat-title">Placement Tests</div>
          <div class="stat-actions">
            <.link navigate={~p"/admin/placement-tests"} class="btn btn-sm btn-accent">Manage</.link>
          </div>
        </div>
        <div class="stat bg-base-200 rounded-box shadow-sm">
          <div class="stat-title">Students</div>
          <div class="stat-value text-accent">{@students_count}</div>
          <div class="stat-actions">
            <.link navigate={~p"/admin/students"} class="btn btn-sm btn-accent">Manage</.link>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <.link navigate={~p"/admin/courses"} class="card bg-base-200 shadow-sm hover:shadow-md transition-shadow">
          <div class="card-body">
            <h2 class="card-title"><.icon name="hero-book-open" class="size-5" /> Courses</h2>
            <p class="text-sm text-base-content/70">Create and manage courses, weeks, and lessons.</p>
          </div>
        </.link>
        <.link navigate={~p"/admin/placement-tests"} class="card bg-base-200 shadow-sm hover:shadow-md transition-shadow">
          <div class="card-body">
            <h2 class="card-title"><.icon name="hero-clipboard-document-check" class="size-5" /> Placement Tests</h2>
            <p class="text-sm text-base-content/70">Manage placement test questions and view results.</p>
          </div>
        </.link>
        <.link navigate={~p"/admin/students"} class="card bg-base-200 shadow-sm hover:shadow-md transition-shadow">
          <div class="card-body">
            <h2 class="card-title"><.icon name="hero-users" class="size-5" /> Students</h2>
            <p class="text-sm text-base-content/70">View students and manage their week access.</p>
          </div>
        </.link>
      </div>
    </Layouts.app>
    """
  end
end
