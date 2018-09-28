defmodule DiscordOauth2Server.Router do
  use Plug.Router
  use Plug.Debugger

  alias DiscordOauth2Server.TokenRequestCache
  alias DiscordOauth2Server.DiscordClient
  alias DiscordOauth2Server.TokenModule
  alias DiscordOauth2Server.Database

  plug(Plug.Logger, log: :debug)
  plug(:match)
  plug(:dispatch)

  get "/login" do
    case DiscordClient.get_referer conn do
      {:ok, referer, _} ->
        state = TokenModule.create_state
        TokenRequestCache.set_state_referer(state, referer)

        conn
        |> put_resp_header("location", DiscordClient.get_auth_url state)
        |> send_resp(301, "Redirection")


      {:error, err} ->
        json = %{status: :error, error: err} |> Jason.encode!
        conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(400, json)
    end
  end


  get "/callback" do
    conn = Plug.Conn.fetch_query_params(conn)
    case conn.query_params do
      %{"state" => state, "code" => code} ->

      case TokenRequestCache.lookup_referer(state) do

        {:not_found} ->
          return_error(conn, 401, "Request token not Found")

        {:found, referer, _state} ->
          %URI{authority: referer_domain, scheme: referer_scheme} = URI.parse referer

          case DiscordClient.get_token code do

            %{access_token: access_token, refresh_token: _} ->
              TokenRequestCache.clear_state(state)
              {_, %{"id" => user_id}} = Poison.decode DiscordClient.get_user(access_token)
              {user_id, _} = Integer.parse user_id
              user =
                case referer_domain do
                  "platform-admin.ftcbot-dev.test" -> Database.fetch_user(user_id)
                   _ -> Database.fetch_guild_user(user_id, referer_domain)
                end
              {:ok, token, _} = TokenModule.create_jwt(user, referer_domain)

              redirect_uri = referer_scheme<>"://"<>referer_domain<>"/login_callback?token="<>token<>"&redirect_uri="<>referer

              conn
              |> put_resp_header("location", redirect_uri)
              |> send_resp(301, "Redirection")

            %{error: _reason} ->
              return_error(conn, 401, "Server Error")
          end
        end
      _ ->
        return_error(conn, 400, "Missing parameter(s)")
    end
  end


  match "public_keys" do
    %{"crv" => crv, "kty" => kty, "x"=>x, "y"=>y} = Application.get_env(:discord_oauth2_server, DiscordOauth2Server.TokenModule)[:secret_key]
    json = %{status: :ok, keys: %{crv: crv, kty: kty, x: x, y: y}}
    |> Jason.encode!

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, json)
  end


  match "/ping" do
    timestamp =
      :os.system_time(:seconds)
      |> Integer.to_string
    json = %{status: :ok, timestamp: timestamp}
      |> Jason.encode!

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, json)
  end


  match _ do
    return_error(conn, 404, "Not found")
  end


  def start_link do
    Plug.Adapters.Cowboy.http(Plugger.Router, [])
  end


  defp return_error(conn, code, msg) do
    json = %{status: :error, reason: msg} |> Jason.encode!
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(code, json)
  end


end
