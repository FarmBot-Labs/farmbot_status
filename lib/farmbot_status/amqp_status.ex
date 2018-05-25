defmodule FarmbotStatus.AMQPStatus do
  use GenServer
  import FarmbotStatus.Config
  import FarmbotStatus.PubSub
  use AMQP
  require Logger

  @exchange "amq.topic"
  @checkup_label "amqp_status"
  @broadcast_name "amqp"

  def status, do: "waiting"

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  defmodule State do
    defstruct [:conn, :chan, :bot, :ping_timeout]
  end

  def init([]) do
    import Farmbot.Jwt, only: [decode: 1]
    with {:ok, %{bot: device, mqtt: mqtt_host, vhost: vhost}} <- decode(token()),
         {:ok, conn}  <- open_connection(token(), device, mqtt_host, vhost),
         {:ok, chan}  <- AMQP.Channel.open(conn),
         q_name       <- uuid("amqp_status"),
         :ok          <- Basic.qos(chan, [global: true]),
         {:ok, _}     <- AMQP.Queue.declare(chan, q_name, [auto_delete: true]),
         :ok          <- AMQP.Queue.bind(chan, q_name, @exchange, [routing_key: to_client(device, ".")]),
         :ok          <- AMQP.Queue.bind(chan, q_name, @exchange, [routing_key: status(device, ".")]),
         :ok          <- AMQP.Queue.bind(chan, q_name, @exchange, [routing_key: sync(device, ".")]),
         :ok          <- AMQP.Queue.bind(chan, q_name, @exchange, [routing_key: logs(device, ".")]),
         {:ok, _tag}  <- Basic.consume(chan, q_name, self(), [no_ack: true]),
         opts      <- [conn: conn, chan: chan, bot: device],
         state <- struct(State, opts)
    do
      {:ok, state}
    end
  end

  def terminate(reason, _state) do
    broadcast(@broadcast_name, "AMQP Disconnect: #{inspect reason}")
  end

  defp open_connection(token, device, mqtt_server, vhost) do
    opts = [
      host: mqtt_server,
      username: device,
      password: token,
      virtual_host: vhost]
    AMQP.Connection.open(opts)
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, _}, state) do
    Logger.info "AMQP Connected!"
    send self(), :checkup
    {:noreply, state}
  end

  # Sent by the broker when the consumer is
  # unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, _}, state) do
    {:stop, :basic_cancel, state}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, _}, state) do
    {:noreply, state}
  end

  def handle_info(:checkup, state) do
    request = %Farmbot.CeleryScript.AST{kind: Farmbot.CeleryScript.AST.Node.RpcRequest, args: %{label: @checkup_label}, body: []}
    {:ok, req} = Farmbot.CeleryScript.AST.encode(request)
    AMQP.Basic.publish state.chan, @exchange, from_clients(state.bot, "."), Poison.encode!(req)
    broadcast(@broadcast_name, :waiting)
    Process.send_after(self(), :checkup, 5000)
    pto = Process.send_after(self(), :rpc_request_timeout, 5000)
    {:noreply, %{state | ping_timeout: pto}}
  end

  def handle_info(:rpc_request_timeout, state) do
    broadcast(@broadcast_name, "rpc request timeout")
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, %{routing_key: key}}, state) do
    route = String.split(key, ".")
    to_client = to_client(state.bot)
    case route do
      ^to_client ->
        {:ok, f} = Farmbot.CeleryScript.AST.decode(payload)
        if to_string(f.args.label) == @checkup_label do
          Process.cancel_timer(state.ping_timeout)
          case f.kind do
            Farmbot.CeleryScript.AST.Node.RpcOk ->
              broadcast(@broadcast_name, :okay)
            Farmbot.CeleryScript.AST.Node.RpcError ->
              broadcast(@broadcast_name, :error)
          end
        end
      _ -> :ok
    end
    # Logger.info "Got data: #{payload} #{inspect key}"
    {:noreply, state}
  end
end
