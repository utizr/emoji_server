defmodule API.MixProject do
  use Mix.Project

  def project do
    [
      app: :api,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {API.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.5"},
      {:cowboy, "~> 1.1.2"},
      {:cors_plug, "~> 1.5"},
      {:poison, "~> 3.1"},
      {:emoji, in_umbrella: true},
    ]
  end
end
