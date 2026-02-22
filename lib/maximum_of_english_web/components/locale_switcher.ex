defmodule MaximumOfEnglishWeb.Components.LocaleSwitcher do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: MaximumOfEnglishWeb.Endpoint,
    router: MaximumOfEnglishWeb.Router,
    statics: MaximumOfEnglishWeb.static_paths()

  attr :conn, Plug.Conn, required: true

  def locale_switcher(assigns) do
    current = Gettext.get_locale(MaximumOfEnglishWeb.Gettext)
    assigns = assign(assigns, :current_locale, current)

    ~H"""
    <div class="flex gap-1">
      <a
        href={"#{current_path(@conn)}?locale=en"}
        class={"btn btn-xs #{if @current_locale == "en", do: "btn-primary", else: "btn-ghost"}"}
      >
        EN
      </a>
      <a
        href={"#{current_path(@conn)}?locale=ru"}
        class={"btn btn-xs #{if @current_locale == "ru", do: "btn-primary", else: "btn-ghost"}"}
      >
        RU
      </a>
    </div>
    """
  end

  defp current_path(conn) do
    conn.request_path
  end
end
