defmodule FarmbotStatus.StatusWorker do
  use Supervisor
  import FarmbotStatus.Config

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    Process.link(Process.whereis(Farmbot.Bootstrap.Supervisor))
    children = [
      {FarmbotStatus.HTTPStatus, []},
      {FarmbotStatus.MQTTStatus, []},
      {FarmbotStatus.AMQPStatus, []},
      {FarmbotStatus.BotStateTransport, []}
    ]
    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end

  def check_and_broadcast do
    Phoenix.PubSub.broadcast(pubsub(), "status", {:http, FarmbotStatus.HTTPStatus.status})
    Phoenix.PubSub.broadcast(pubsub(), "status", {:mqtt, FarmbotStatus.MQTTStatus.status})
    Phoenix.PubSub.broadcast(pubsub(), "status", {:amqp, FarmbotStatus.AMQPStatus.status})
  end
end
