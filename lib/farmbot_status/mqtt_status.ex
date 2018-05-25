defmodule FarmbotStatus.MQTTStatus do
  use GenMQTT
  import FarmbotStatus.Config
  import FarmbotStatus.PubSub
  require Logger

  @broadcast_name "mqtt"
  @checkup_label "mqtt_status"

  def status, do: "waiting"

  def start_link(_) do
    {:ok, %{
      bot: bot,
      mqtt: host,
    } = jwt} = Farmbot.Jwt.decode(token())
    GenMQTT.start_link(__MODULE__, [jwt], [name: __MODULE__, password: token(), username: bot, client: uuid("mqtt_status"), host: host])
  end

  def init([jwt]) do
    {:ok, %{jwt: jwt}}
  end

  def terminate(reason, _state) do
    Logger.error("MQTT down!")
    broadcast(@broadcast_name, "MQTT Disconnect: #{inspect reason}")
  end

  def on_connect_error(reason, _state) do
    Logger.error("MQTT failed to connect! #{inspect reason}")
  end

  def on_connect(_) do
    {:ok, jwt} = Farmbot.Jwt.decode(token())
    :ok = GenMQTT.subscribe(self(), to_client(jwt.bot, "/"), 0)
    :ok = GenMQTT.subscribe(self(), status(jwt.bot, "/"), 0)
    :ok = GenMQTT.subscribe(self(), sync(jwt.bot, "/"), 0)
    :ok = GenMQTT.subscribe(self(), logs(jwt.bot, "/"), 0)
    Logger.info "MQTT Up!"

    send(self(), :checkup)
    {:ok, %{jwt: jwt, rpc_request_timeout: nil}}
  end

  def handle_info(:checkup, state) do
    request = %Farmbot.CeleryScript.AST{kind: Farmbot.CeleryScript.AST.Node.RpcRequest, args: %{label: @checkup_label}, body: []}
    {:ok, req} = Farmbot.CeleryScript.AST.encode(request)
    GenMQTT.publish(self(), from_clients(state.jwt.bot, "/"), Poison.encode!(req), 0)
    broadcast(@broadcast_name, :waiting)
    Process.send_after(self(), :checkup, 5000)
    pto = Process.send_after(self(), :rpc_request_timeout, 5000)
    {:ok, %{state | rpc_request_timeout: pto}}
  end

  def handle_info(:rpc_request_timeout, state) do
    broadcast(@broadcast_name, "rpc request timeout")
    {:ok, state}
  end

  def on_publish(route, payload, state) do
    to_client = to_client(state.jwt.bot)
    case route do
      ^to_client ->
        {:ok, f} = Farmbot.CeleryScript.AST.decode(payload)
        if to_string(f.args.label) == @checkup_label do
          Process.cancel_timer(state.rpc_request_timeout)
          case f.kind do
            Farmbot.CeleryScript.AST.Node.RpcOk ->
              broadcast(@broadcast_name, :okay)
            Farmbot.CeleryScript.AST.Node.RpcError ->
              broadcast(@broadcast_name, :error)
          end
        end
      _ -> :ok
    end
    {:ok, state}
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

end
