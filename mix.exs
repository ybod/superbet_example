defmodule Superbet.MixProject do
  use Mix.Project

  def project do
    [
      app: :superbet,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.16"},
      {:jason, "~> 1.2"}
    ]
  end
end
