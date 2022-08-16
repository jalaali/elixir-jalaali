defmodule Jalaali.Mixfile do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      app: :jalaali,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: [
        source_ref: "v#{@version}",
        main: "readme",
        canonical: "http://hexdocs.pm/jalaali",
        source_url: "https://github.com/jalaali/elixir-jalaali",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Elixir Shamsi calendar. A Jalaali (Jalali, Persian, Khorshidi, Shamsi) calendar system implemention for Elixir.
    """
  end

  defp package do
    [
      name: :jalaali,
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Alisina Bahadori", "Shahryar Tavakkoli"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jalaali/elixir-jalaali"}
    ]
  end
end
