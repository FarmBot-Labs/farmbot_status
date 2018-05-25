defmodule FarmbotStatus.BotStateTransport do
  use GenStage
  import FarmbotStatus.Config
  import FarmbotStatus.PubSub

  def start_link(_) do
    GenStage.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    {:consumer, %{}, subscribe_to: [Farmbot.BotState, Farmbot.Logger]}
  end


  def handle_events(events, {pid, _}, state) do
    events = Enum.reject(events, fn(event) -> match?({:emit, _}, event) end)
    case Process.info(pid)[:registered_name] do
      Farmbot.Logger -> handle_log_events(events, state)
      Farmbot.BotState -> handle_bot_state_events(events, state)
    end
  end

  def handle_log_events(events, state) do
    for log <- events do
      broadcast("bot_log", log)
    end
    {:noreply, [], state}
  end

  def handle_bot_state_events(events, state) do
    e = List.last(events)
    if e do
      broadcast("bot_state", e)
    end
    {:noreply, [], state}
  end
end
