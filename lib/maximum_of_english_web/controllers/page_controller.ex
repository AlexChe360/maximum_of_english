defmodule MaximumOfEnglishWeb.PageController do
  use MaximumOfEnglishWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
