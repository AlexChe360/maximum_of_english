defmodule MaximumOfEnglishWeb.Admin.PlacementResultLive.Index do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Placement

  @impl true
  def mount(_params, _session, socket) do
    results = Placement.list_results()

    socket =
      socket
      |> assign(page_title: "Placement Results")
      |> assign(results: results)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Placement Results
        <:subtitle>{length(@results)} submissions</:subtitle>
      </.header>

      <.table id="placement-results" rows={@results}>
        <:col :let={result} label="Name">{result.name}</:col>
        <:col :let={result} label="Email">{result.email}</:col>
        <:col :let={result} label="Phone">{result.phone || "—"}</:col>
        <:col :let={result} label="Score">{result.score}</:col>
        <:col :let={result} label="Level">
          <span class="badge badge-primary">{result.level}</span>
        </:col>
        <:col :let={result} label="Date">
          {Calendar.strftime(result.inserted_at, "%Y-%m-%d %H:%M")}
        </:col>
      </.table>

      <.link navigate={~p"/admin"} class="btn btn-ghost btn-sm mt-4">
        <.icon name="hero-arrow-left" class="size-4" /> Back
      </.link>
    </Layouts.app>
    """
  end
end
