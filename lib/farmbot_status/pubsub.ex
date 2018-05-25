defmodule FarmbotStatus.PubSub do
  import FarmbotStatus.Config
  
  def subscribe do
    Phoenix.PubSub.subscribe(pubsub(), "status")
  end

  def broadcast(kind, msg) do
    Phoenix.PubSub.broadcast(pubsub(), "status", {kind, msg})
  end
end
