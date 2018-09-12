defmodule DiscordOauth2Server.Router do
  use Plug.Router
  use Plug.Debugger

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)


  Plug.Router.get "/login" do
    conn
    |> put_resp_header("location", DiscordOauth2Server.DiscordClient.get_auth_url)
    |> send_resp(302, "Redirection")
  end


  Plug.Router.get "/callback" do
    conn = Plug.Conn.fetch_query_params(conn)
    params = conn.query_params
    state = params["state"]
    code = params["code"]

    token = DiscordOauth2Server.DiscordClient.get_token code
    body = DiscordOauth2Server.DiscordClient.get_user token.access_token

    send_resp(conn, 200, "user: " <> body)
  end


  match _ do
      send_resp(conn, 404, "not founds")
  end

  def start_link do
    Plug.Adapters.Cowboy.http(Plugger.Router, [])
  end
end
