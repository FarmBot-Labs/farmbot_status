defmodule FarmbotStatus.Mixfile do
  use Mix.Project
  System.put_env("MIX_TARGET", "host")

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
      {:distillery, "~> 1.0"},
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0", override: true},
      {:ranch, "~> 1.4", override: true},

      {:amqp, "~> 1.0"},
      # {:tortoise, "~> 0.1.0"},
      {:gen_mqtt, "~> 0.4.0"},

      {:farmbot, github: "FarmBot/farmbot_os", branch: "deleteme", submodules: true, env: :dev},
      {:nerves, "~> 1.0"},
      {:nerves_bootstrap, "~> 1.0", runtime: false},
      {:gen_stage, "~> 0.13.1"},
      {:ex_doc, "~> 0.18.3"},
      {:inch_ex, "~> 0.5.6"}
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
