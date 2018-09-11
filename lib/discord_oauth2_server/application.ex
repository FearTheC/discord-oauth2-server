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

    # Define workers and child supervisors to be supervised
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, DiscordOauth2Server.Router, [], cowboy_options)
      # Starts a worker by calling: DiscordOauth2Server.Worker.start_link(arg1, arg2, arg3)
      # worker(DiscordOauth2Server.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DiscordOauth2Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
