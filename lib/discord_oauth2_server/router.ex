defmodule DiscordOauth2Server.Router do
  use Plug.Router
  use Plug.Debugger
  require Logger
  require OAuth2
  use OAuth2.Strategy

  @base_url "https://discordapp.com/api"
  @token_uri @base_url <> "/oauth2/token"
  @auth_url @base_url <> "/oauth2/authorize"
  @user_url @base_url <> "/users/@me"
  @redirect_uri "http://discord-oauth.fearthec.test:8085/callback"
  @client_id Application.get_env(:discord_oauth2_server, :client_id)
  @client_secret Application.get_env(:discord_oauth2_server, :client_secret)

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)




  def client do
    OAuth2.Client.new([
      strategy: OAuth2.Strategy.AuthCode,
      client_id: @client_id,
      client_secret: @client_secret,
      authorize_url: @auth_url,
      token_url: @token_uri,
      redirect_uri: @redirect_uri
    ])
  end


  Plug.Router.get "/hello" do
    IO.inspect Application.get_env(:discord_oauth2_server, :client_test)
    send_resp(conn, 200, @auth_url)
  end


  Plug.Router.get "/login" do
    length = 24
    state = :crypto.strong_rand_bytes(length)
      |> Base.url_encode64
      |> binary_part(0, length)

    url = OAuth2.Client.authorize_url!(client, scope: "identify email", state: state)

    conn
      |> put_resp_header("location", url)
      |> send_resp(302, "Redirection")
  end


  Plug.Router.get "/callback" do
    conn = Plug.Conn.fetch_query_params(conn)
    params = conn.query_params
    state = params["state"]
    code = params["code"]
    headers = [{"Content-Type", "application/x-www-form-urlencoded"}]

    query = client
    |> put_param(:client_id, @client_id)
    |> put_param(:client_secret, client.client_secret)
    |> put_param(:redirect_uri, client.redirect_uri)
    |> put_param(:code, code)
    |> put_param(:scope, "identify email")
    |> put_param(:grant_type, "authorization_code")
    |> put_header("accept", "application/x-www-form-urlencoded")

    {:ok, res} = OAuth2.Client.get_token(query)

    headers = [
      {"Authorization", "Bearer " <> res.token.access_token}
    ]
    %HTTPoison.Response{status_code: status, body: body} = HTTPoison.get!(@user_url, headers)


      send_resp(conn, 200, "user: " <> body)
  end

  # Basic example to handle POST requests wiht a JSON body
  Plug.Router.post "/post" do
      {:ok, body, conn} = read_body(conn)
      body = Poison.decode!(body)
      IO.inspect(body)
      send_resp(conn, 201, "created: #{get_in(body, ["message"])}")
  end

  # "Default" route that will get called when no other route is matched
  match _ do
      send_resp(conn, 404, "not founds")
  end

  def start_link do
    Plug.Adapters.Cowboy.http(Plugger.Router, [])
  end
end
