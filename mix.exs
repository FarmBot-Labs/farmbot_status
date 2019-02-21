defmodule FarmbotStatus.Mixfile do
  use Mix.Project
  System.put_env("MIX_TARGET", "host")
  old = System.get_env("CFLAGS")
  System.put_env("CFLAGS", "#{old} --std=c99")

  def project do
    [
      app: :farmbot_status,
      version: "0.0.2",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {FarmbotStatus.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:phoenix, "~> 1.4"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0", override: true},

      {:amqp, "~> 1.0"},
            {:ranch, "1.6.2", override: true},
{:ranch_proxy_protocol, "~> 2.1", override: true},
      # {:tortoise, "~> 0.1.0"},
      {:gen_mqtt, "~> 0.4.0"},

      {:farmbot, github: "FarmBot/farmbot_os", tag: "v7.0.1", env: :dev},
      {:nerves, "~> 1.4"},
      {:nerves_bootstrap, "~> 1.4", runtime: false},
      {:gen_stage, "~> 0.14"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
