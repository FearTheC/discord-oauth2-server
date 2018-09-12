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


  def get_auth_url do
    length = 24
    state = :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)

    @auth_url <> "?client_id=" <> @client_id <> "&redirect_uri="<>@redirect_uri<>"&response_type=code&scope=identify+email&state="<>state
  end


  def get_token(code) do
    headers = %{"content-type" => "application/x-www-form-urlencoded"}
    body = {:form, [
      client_id: @client_id,
      client_secret: @client_secret,
      redirect_uri: @redirect_uri,
      code: code,
      scope: "identify email",
      grant_type: "authorization_code"
    ]}

    {:ok, %HTTPoison.Response{body: token}} = HTTPoison.post(@token_uri, body, headers, [])

    token = Poison.decode! token

    for {key, val} <- token, into: %{}, do: {String.to_atom(key), val}
  end


  def get_user(access_token) do
    headers = [
      {"Authorization", "Bearer " <> access_token}
    ]
    %HTTPoison.Response{status_code: status, body: body} = HTTPoison.get!(@user_url, headers)

    body
  end

end
