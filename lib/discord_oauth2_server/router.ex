defmodule DiscordOauth2Server.Router do
  use Plug.Router
  use Plug.Debugger

  alias DiscordOauth2Server.TokenRequestCache
  alias DiscordOauth2Server.DiscordClient

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  get "/login" do
    case DiscordClient.get_referer conn do
      {:ok, referer, _} ->
        state = DiscordClient.create_state
        TokenRequestCache.set_state_referer(state, referer)

        conn
        |> put_resp_header("location", DiscordOauth2Server.DiscordClient.get_auth_url state)
        |> send_resp(301, "Redirection")

      {:error, _} ->
        conn
        |> send_resp(400, "ERROR")
    end
  end


  get "/callback" do
    conn = Plug.Conn.fetch_query_params(conn)
    params = conn.query_params
    state = params["state"]
    code = params["code"]

    referer = TokenRequestCache.lookup_referer! state
    %URI{authority: referer_domain, scheme: referer_scheme} = URI.parse referer

    case DiscordOauth2Server.DiscordClient.get_token code do

      %{access_token: access_token, refresh_token: _} ->
        {_, %{"id" => user_id}} = Poison.decode DiscordOauth2Server.DiscordClient.get_user access_token
        {user_id, _} = Integer.parse user_id
        user = DiscordOauth2Server.Database.fetch_guild_user(user_id, referer_domain)
        {:ok, token, _} = DiscordClient.create_jwt user, referer_domain

        redirect_uri = referer_scheme<>"://"<>referer_domain<>"/login_callback?token="<>token<>"&redirect_uri="<>referer

        conn
        |> put_resp_header("location", redirect_uri)
        |> send_resp(301, "Redirection")

      %{error: reason} ->
        %{error: reason}
        send_resp(conn, 500, "Server Error")
    end
  end


  match _ do
      send_resp(conn, 404, "not founds")
  end

  def start_link do
    Plug.Adapters.Cowboy.http(Plugger.Router, [])
  end


end
