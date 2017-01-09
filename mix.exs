defmodule Periodic.Mixfile do
  use Mix.Project

  def project do
    [app: :periodic,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application, do: [applications: [:logger]]
  def aliases, do: []
  defp deps, do: []
end
