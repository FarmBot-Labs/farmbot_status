defmodule FarmbotStatusWeb.RoomChannel do
  use Phoenix.Channel
  import FarmbotStatus.Config

  def join("room:lobby", _message, socket) do
    Phoenix.PubSub.subscribe(pubsub(), "status")
    Process.send_after(self(), :checkup, 100)
    {:ok, socket}
  end

  def handle_info({"bot_state", state}, socket) do
    push socket, "bot_state_update", state
    {:noreply, socket}
  end

  def handle_info({"bot_log", log}, socket) do
    push socket, "bot_log", log
    {:noreply, socket}
  end

  def handle_info({service, status}, socket) do
    push socket, "status_update", %{service: service, status: status}
    {:noreply, socket}
  end

  def handle_info(:checkup, socket) do
    FarmbotStatus.StatusWorker.check_and_broadcast()
    {:noreply, socket}
  end

end
