# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :farmbot_status,
  ecto_repos: [FarmbotStatus.Repo]

# Configures the endpoint
config :farmbot_status, FarmbotStatusWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HVDHeBHrP4FE1OC+zE07CA8E0XUgbbwdrnQK2DEERMGm5pRmSkq49k611hqITZTf",
  render_errors: [view: FarmbotStatusWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FarmbotStatus.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "fbos_config.exs"
import_config "#{Mix.env}.exs"

config :logger, backends: [:console]
