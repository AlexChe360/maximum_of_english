defmodule MaximumOfEnglishWeb.Router do
  use MaximumOfEnglishWeb, :router

  import MaximumOfEnglishWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MaximumOfEnglishWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug MaximumOfEnglishWeb.Plugs.SetLocale
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public pages
  scope "/", MaximumOfEnglishWeb do
    pipe_through :browser

    live_session :public,
      on_mount: [{MaximumOfEnglishWeb.UserAuth, :mount_current_scope}] do
      live "/", LandingLive
      live "/placement", PlacementLive
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:maximum_of_english, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MaximumOfEnglishWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MaximumOfEnglishWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MaximumOfEnglishWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  # Student routes
  scope "/", MaximumOfEnglishWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :student,
      on_mount: [{MaximumOfEnglishWeb.UserAuth, :require_student}] do
      live "/dashboard", StudentDashboardLive
    end
  end

  # Admin uploads (non-LiveView, for editor image uploads)
  scope "/admin", MaximumOfEnglishWeb do
    pipe_through [:browser, :require_authenticated_user]

    post "/upload", UploadController, :create
  end

  # Admin routes
  scope "/admin", MaximumOfEnglishWeb.Admin do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admin,
      on_mount: [{MaximumOfEnglishWeb.UserAuth, :require_admin}] do
      live "/", DashboardLive
      live "/courses", CourseLive.Index
      live "/courses/new", CourseLive.Form
      live "/courses/:id/edit", CourseLive.Form
      live "/courses/:course_id/weeks", WeekLive.Index
      live "/courses/:course_id/weeks/new", WeekLive.Form
      live "/courses/:course_id/weeks/:id/edit", WeekLive.Form
      live "/weeks/:week_id/lessons", LessonLive.Index
      live "/weeks/:week_id/lessons/new", LessonLive.Form
      live "/weeks/:week_id/lessons/:id/edit", LessonLive.Form
      live "/lessons/:lesson_id/test", TestLive.Form
      live "/placement-tests", PlacementTestLive.Index
      live "/placement-tests/:id/edit", PlacementTestLive.Form
      live "/placement-results", PlacementResultLive.Index
      live "/students", StudentLive.Index
      live "/students/:id/progress", StudentLive.Progress
    end
  end

  scope "/", MaximumOfEnglishWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{MaximumOfEnglishWeb.UserAuth, :mount_current_scope}] do
      live "/users/log-in", UserLive.Login, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
