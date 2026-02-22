defmodule MaximumOfEnglishWeb.Plugs.SetLocale do
  @moduledoc """
  Plug to set the locale from session or query params.
  """
  import Plug.Conn

  @supported_locales ~w(en ru)
  @default_locale "en"

  def init(opts), do: opts

  def call(conn, _opts) do
    locale =
      conn.params["locale"] ||
        get_session(conn, :locale) ||
        @default_locale

    locale = if locale in @supported_locales, do: locale, else: @default_locale

    Gettext.put_locale(MaximumOfEnglishWeb.Gettext, locale)

    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end
end
