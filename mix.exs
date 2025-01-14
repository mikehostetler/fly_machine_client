defmodule FlyMachineClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :fly_machine_client,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
    ]
  end

  defp aliases do
    [
      test: "test --trace"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.20"},
      {:nimble_options, "~> 1.1"},
      {:tesla, "~> 1.13"},

      # Testing
      {:credo, "~> 1.7"},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:doctor, "~> 0.22.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18.3", only: [:dev, :test]},
      {:exvcr, "~> 0.15.2", only: [:dev, :test]},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.1", only: [:dev, :test]}
    ]
  end
end
