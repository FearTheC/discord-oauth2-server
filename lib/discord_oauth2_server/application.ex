defmodule DiscordOauth2Server.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application



  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    cowboy_options = [
      port: 8085
    ]
    Postgrex.Types.define(DiscordOauth2Server.PostgrexTypes, [], json: Jason)
    postgrex_options = Keyword.put(Application.get_env(:discord_oauth2_server, :db), :name, DB)

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, DiscordOauth2Server.Router, [], cowboy_options),
      Postgrex.child_spec(postgrex_options),
      worker(DiscordOauth2Server.TokenRequestCache, []),
      worker(DiscordOauth2Server.TokenCache, [])

    ]

    opts = [strategy: :one_for_one, name: DiscordOauth2Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
