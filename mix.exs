defmodule DiscordOauth2Server.Mixfile do
  use Mix.Project

  defp description do
    """
    Server acting as a proxy for Discord OAuth2 service, providing JWS token for storage-less sessions
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Quentin Bonaventure"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fearthec/discord-oauth-server"}
    ]
  end

  def project do
    [app: :discord_oauth2_server,
     version: "0.1.1",
     elixir: "~> 1.7",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :postgrex, :cowboy, :plug, :eex],
     mod: {DiscordOauth2Server.Application, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:postgrex, "~> 0.13"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.5"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:poolboy, "~> 1.5"},
      {:jason, "~> 1.1"},
      {:joken, "~> 1.5.0"},
      {:guardian, "~> 1.1"},
      {:distillery, "~> 2.0", runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
