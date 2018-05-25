use Mix.Config

# Stop lager redirecting :error_logger messages
config :lager, :error_logger_redirect, false

# Stop lager removing Logger's :error_logger handler
config :lager, :error_logger_whitelist, []

# Stop lager writing a crash log
config :lager, :crash_log, false

# Use LagerLogger as lager's only handler.
config :lager, :handlers, []

config :elixir, ansi_enabled: true
config :iex, :colors, enabled: true

config :ssl, protocol_version: :"tlsv1.2"

config :farmbot, farm_event_debug_log: false

# Configure Farmbot Behaviours.
config :farmbot, :behaviour, [
  authorization: Farmbot.Bootstrap.Authorization,
  firmware_handler: Farmbot.Firmware.StubHandler,
  http_adapter: Farmbot.HTTP.HTTPoisonAdapter,
  gpio_handler: Farmbot.System.GPIO.StubHandler,
  system_tasks: Farmbot.Host.SystemTasks,
  update_handler: Farmbot.Host.UpdateHandler,
]

config :farmbot, :farmware,
  first_part_farmware_manifest_url: nil

config :farmbot,
  expected_fw_versions: ["6.4.0.F", "6.4.0.R", "6.4.0.G"],
  default_server: "https://my.farm.bot",
  default_currently_on_beta: false,
  firmware_io_logs: false,
  default_farmware_tools_release_url: "https://api.github.com/repos/FarmBot-Labs/farmware-tools/releases/11015343",
  ecto_repos: [Farmbot.Repo, Farmbot.System.ConfigStorage]

  config :farmbot, data_path: "/tmp/fbos_data/"

  # Configure your our system.
  # Default implementation needs no special stuff.
  config :farmbot, :init, [
    Farmbot.Host.Bootstrap.Configurator,
    Farmbot.System.Debug
  ]

  # Transports.
  config :farmbot, :transport, [
    Farmbot.BotState.Transport.AMQP,
    Farmbot.BotState.Transport.HTTP,
  ]

  config :farmbot, Farmbot.Repo,
    adapter: Sqlite.Ecto2,
    loggers: [],
    database: "/tmp/fbos_data/repo.sqlite3",
    pool_size: 1

  config :farmbot, Farmbot.System.ConfigStorage,
    adapter: Sqlite.Ecto2,
    loggers: [],
    database: "/tmp/fbos_data/config_storage.sqlite3",
    pool_size: 1
