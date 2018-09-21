defmodule DiscordOauth2Server.DiscordClient do
  alias DiscordOauth2Server.TokenModule
  alias DiscordOauth2Server.TokenCache

  def base_url, do: "https://discordapp.com/api"
  def token_uri, do: base_url() <> "/oauth2/token"
  def auth_url, do: base_url() <> "/oauth2/authorize"
  def user_url, do: base_url() <> "/users/@me"
  def redirect_uri, do: Application.get_env :discord_oauth2_server, :redirect_uri
  def client_id, do: Application.get_env :discord_oauth2_server, :client_id
  def client_secret, do: Application.get_env :discord_oauth2_server, :client_secret


  def create_jwt user, referer do
    {:ok, jwt, claims} = TokenModule.encode_and_sign(user, [aud: referer])
    TokenCache.set_new_token(jwt, claims["jti"])
    {:ok, jwt, claims}
  end


  def get_referer conn do
    case List.keyfind(conn.req_headers, "referer", 0) do
      {"referer", referer} ->
        %URI{authority: referer_domain} = URI.parse referer
        {:ok, referer, referer_domain}
      nil -> {:error, "No referer provided."}
    end
  end


  def create_state do
    length = 24
    :crypto.strong_rand_bytes(length)
      |> Base.url_encode64
      |> binary_part(0, length)
  end

  def get_auth_url state do
    auth_url() <> "?client_id=" <> client_id() <> "&redirect_uri="<>redirect_uri()<>"&response_type=code&scope=identify+email&state="<>state
  end


  def get_token(code) do
    headers = %{"content-type" => "application/x-www-form-urlencoded"}
    form = {:form, [
      client_id: client_id(),
      client_secret: client_secret(),
      redirect_uri: redirect_uri(),
      code: code,
      scope: "identify email",
      grant_type: "authorization_code"
    ]}

    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.post(token_uri(), form, headers, [])

    body = Poison.decode! body
    for {key, val} <- body, into: %{}, do: {String.to_atom(key), val}

  end


  def get_user(access_token) do
    headers = [
      {"Authorization", "Bearer " <> access_token}
    ]

    %HTTPoison.Response{status_code: _status, body: body} = HTTPoison.get!(user_url(), headers)

    body
  end

end
