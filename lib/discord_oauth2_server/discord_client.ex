defmodule DiscordOauth2Server.DiscordClient do
  require OAuth2
  use OAuth2.Strategy

  @base_url "https://discordapp.com/api"
  @token_uri @base_url <> "/oauth2/token"
  @auth_url @base_url <> "/oauth2/authorize"
  @user_url @base_url <> "/users/@me"
  @redirect_uri Application.get_env :discord_oauth2_server, :redirect_uri
  @client_id Application.get_env :discord_oauth2_server, :client_id
  @client_secret Application.get_env :discord_oauth2_server, :client_secret


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


  def get_auth_url do
    length = 24
    state = :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)

    @auth_url <> "?client_id=" <> @client_id <> "&redirect_uri="<>@redirect_uri<>"&response_type=code&scope=identify+email&state="<>state
  end


  def get_token(code) do
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

    res.token
  end


  def get_user(access_token) do
    headers = [
      {"Authorization", "Bearer " <> access_token}
    ]
    %HTTPoison.Response{status_code: status, body: body} = HTTPoison.get!(@user_url, headers)

    body
  end

end