defmodule Jalaali.Mixfile do
  use Mix.Project

  def project do
    [app: :jalaali,
     version: "0.1.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
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
      {:ex_doc, "~> 0.14", only: :dev},
      {:earmark, "~> 1.0", only: :dev}
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
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Alisina Bahadori"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/jalaali/elixir-jalaali"}
    ]
  end
end
