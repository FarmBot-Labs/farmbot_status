defmodule FarmbotStatus.HTTPStatus do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init([]) do
    :ignore
  end

  def status do
    case Farmbot.HTTP.get("/api/sequences") do
      {:ok, %{status_code: 200}} -> "okay"
      {:ok, %{status_code: code}} -> "Error reaching: #{code}"
      {:error, reason} -> inspect(reason)
    end
  end
end
