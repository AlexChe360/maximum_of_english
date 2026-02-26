defmodule MaximumOfEnglishWeb.Admin.PlacementTestLive.Index do
  use MaximumOfEnglishWeb, :live_view

  alias MaximumOfEnglish.Placement

  @impl true
  def mount(_params, _session, socket) do
    tests = Placement.list_tests()

    socket =
      socket
      |> assign(page_title: "Placement Tests")
      |> assign(tests: tests)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Placement Tests
        <:actions>
          <button phx-click="create_test" class="btn btn-primary btn-sm">
            <.icon name="hero-plus" class="size-4" /> New Test
          </button>
        </:actions>
      </.header>

      <.table id="placement-tests" rows={@tests}>
        <:col :let={test} label="Title">{test.title}</:col>
        <:col :let={test} label="Active">
          <span class={"badge #{if test.is_active, do: "badge-success", else: "badge-error"}"}>
            {if test.is_active, do: "Yes", else: "No"}
          </span>
        </:col>
        <:action :let={test}>
          <.link navigate={~p"/admin/placement-tests/#{test.id}/edit"} class="link link-primary text-sm mr-3">
            Edit
          </.link>
          <.link phx-click="toggle_active" phx-value-id={test.id} class={"link text-sm mr-3 #{if test.is_active, do: "link-warning", else: "link-success"}"}>
            {if test.is_active, do: "Deactivate", else: "Activate"}
          </.link>
          <.link phx-click="delete" phx-value-id={test.id} data-confirm="Delete this test?" class="link link-error text-sm">
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
  def handle_event("create_test", _params, socket) do
    {:ok, _} = Placement.create_test(%{title: "Placement Test #{length(socket.assigns.tests) + 1}"})
    {:noreply, assign(socket, tests: Placement.list_tests())}
  end

  @impl true
  def handle_event("toggle_active", %{"id" => id}, socket) do
    test = Placement.get_test!(id)
    {:ok, _} = Placement.update_test(test, %{is_active: !test.is_active})
    {:noreply, assign(socket, tests: Placement.list_tests())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    test = Placement.get_test!(id)
    {:ok, _} = Placement.delete_test(test)
    {:noreply, assign(socket, tests: Placement.list_tests())}
  end
end
