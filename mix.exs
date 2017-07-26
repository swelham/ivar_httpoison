defmodule Ivar.Httpoison.Mixfile do
  use Mix.Project

  def project do
    [app: :ivar_httpoison,
     version: "0.1.0",
     elixir: "~> 1.4",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :httpoison]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.11.0"},
      {:idna, "~> 4.0"},

      # dev/test deps
      {:ivar, git: "https://github.com/swelham/ivar.git", branch: "adapter-refactor", only: :test},
      {:poison, "~> 3.0", only: :test},
      {:ex_doc, "~> 0.16", only: :dev},
      {:bypass, "~> 0.6.0", only: :test}
    ]
  end

  defp description do
    "An HTTPoison adapter for the Ivar HTTP client"
  end

  defp package do
    [name: :ivar_httpoison,
     maintainers: ["swelham"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/swelham/ivar_httpoison"}]
  end
end
