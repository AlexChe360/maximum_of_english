defmodule MaximumOfEnglishWeb.LandingLive do
  use MaximumOfEnglishWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: gettext("Welcome"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <%!-- Hero Section --%>
      <section class="hero min-h-[50vh] sm:min-h-[60vh] bg-base-200 rounded-box">
        <div class="hero-content text-center px-4">
          <div class="max-w-2xl">
            <h1 class="text-3xl sm:text-5xl font-bold text-primary">Maximum of English</h1>
            <p class="py-4 sm:py-6 text-base sm:text-lg text-base-content/80">
              {gettext("Your personal path to fluency. Learn English with structured courses, weekly lessons, and progress tracking — all guided by a curator.")}
            </p>
            <div class="flex flex-col sm:flex-row gap-3 sm:gap-4 justify-center">
              <.link navigate={~p"/placement"} class="btn btn-primary btn-md sm:btn-lg">
                {gettext("Take Placement Test")}
              </.link>
              <.link navigate={~p"/users/log-in"} class="btn btn-outline btn-md sm:btn-lg">
                {gettext("Log in")}
              </.link>
            </div>
          </div>
        </div>
      </section>

      <%!-- How It Works --%>
      <section class="py-8 sm:py-12">
        <h2 class="text-2xl sm:text-3xl font-bold text-center mb-6 sm:mb-8">{gettext("How It Works")}</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-6">
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body items-center text-center">
              <div class="badge badge-primary badge-lg text-lg font-bold w-10 h-10">1</div>
              <h3 class="card-title">{gettext("Placement Test")}</h3>
              <p class="text-sm text-base-content/70">{gettext("Take a quick test to determine your English level.")}</p>
            </div>
          </div>
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body items-center text-center">
              <div class="badge badge-primary badge-lg text-lg font-bold w-10 h-10">2</div>
              <h3 class="card-title">{gettext("Get Your Level")}</h3>
              <p class="text-sm text-base-content/70">{gettext("Receive your level assessment from Beginner to C1.")}</p>
            </div>
          </div>
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body items-center text-center">
              <div class="badge badge-primary badge-lg text-lg font-bold w-10 h-10">3</div>
              <h3 class="card-title">{gettext("Join a Course")}</h3>
              <p class="text-sm text-base-content/70">{gettext("Get assigned to a structured course with weekly content.")}</p>
            </div>
          </div>
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body items-center text-center">
              <div class="badge badge-primary badge-lg text-lg font-bold w-10 h-10">4</div>
              <h3 class="card-title">{gettext("Learn & Progress")}</h3>
              <p class="text-sm text-base-content/70">{gettext("Study Grammar, Reading, Listening. Pass tests and advance.")}</p>
            </div>
          </div>
        </div>
      </section>

      <%!-- Features --%>
      <section class="py-8 sm:py-12">
        <h2 class="text-2xl sm:text-3xl font-bold text-center mb-6 sm:mb-8">{gettext("What You Get")}</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body">
              <h3 class="card-title">
                <.icon name="hero-book-open" class="size-6 text-primary" /> {gettext("Grammar")}
              </h3>
              <p class="text-sm text-base-content/70">{gettext("Video lessons and downloadable materials to master English grammar.")}</p>
            </div>
          </div>
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body">
              <h3 class="card-title">
                <.icon name="hero-document-text" class="size-6 text-primary" /> {gettext("Reading")}
              </h3>
              <p class="text-sm text-base-content/70">{gettext("Engaging texts with vocabulary to build your reading comprehension.")}</p>
            </div>
          </div>
          <div class="card bg-base-200 shadow-sm">
            <div class="card-body">
              <h3 class="card-title">
                <.icon name="hero-speaker-wave" class="size-6 text-primary" /> {gettext("Listening")}
              </h3>
              <p class="text-sm text-base-content/70">{gettext("Audio exercises to improve your listening skills and pronunciation.")}</p>
            </div>
          </div>
        </div>
      </section>

      <%!-- CTA --%>
      <section class="py-12 text-center">
        <div class="card bg-primary text-primary-content shadow-lg">
          <div class="card-body">
            <h2 class="card-title justify-center text-2xl">{gettext("Ready to Start?")}</h2>
            <p>{gettext("Take your placement test now and begin your English learning journey.")}</p>
            <div class="card-actions justify-center mt-4">
              <.link navigate={~p"/placement"} class="btn btn-secondary btn-lg">
                {gettext("Start Placement Test")}
              </.link>
            </div>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
