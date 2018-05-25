defmodule FarmbotStatus.Config do
  @moduledoc "Config data."

  def email do
    Application.get_env(:farmbot, :authorization)[:email]
  end

  def server do
    Application.get_env(:farmbot, :authorization)[:server]
  end

  def token do
    Farmbot.System.ConfigStorage.get_config_value(:string, "authorization", "token")
  end

  def pubsub do
    Application.get_all_env(:farmbot_status)[FarmbotStatusWeb.Endpoint][:pubsub][:name]
  end

  def uuid(client) do
    client <> "-" <> UUID.uuid1
  end

  def to_client(uuid, seperator), do: Enum.join(to_client(uuid), seperator)
  def to_client(uuid), do: ["bot", uuid, "from_device"]

  def from_clients(uuid, seperator), do: ["bot", uuid, "from_clients"] |> Enum.join(seperator)
  def status(uuid, seperator), do: ["bot", uuid, "status"] |> Enum.join(seperator)
  def sync(uuid, seperator), do: ["bot", uuid, "sync", "#"] |> Enum.join(seperator)
  def logs(uuid, seperator), do: ["bot", uuid, "logs"] |> Enum.join(seperator)
end
