defmodule Jalaali.Mixfile do
  use Mix.Project

  @version "0.3.0"

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

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
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
      maintainers: ["Alisina Bahadori"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jalaali/elixir-jalaali"}
    ]
  end
end
