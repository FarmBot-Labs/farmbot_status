defmodule FarmbotStatusWeb.PageController do
  use FarmbotStatusWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
