defmodule DiscordOauth2Server.TokenModule do
  use Guardian, otp_app: :discord_oauth2_server

  alias DiscordOauth2Server.User
  alias DiscordOauth2Server.Database

  @config Application.get_env(:discord_oauth2_server, __MODULE__)


  def subject_for_token(%User{id: id}, _claims) do
    {:ok, "User:#{id}"}
  end

  def subject_for_token(_, _), do: {:error, :unhandled_resource_type}



  def resource_from_claims(%{"sub" => "User:" <> id}) do
    case Database.get_user(id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end


  def create_token(mod, claims, options) do
    {:ok, Guardian.Token.Jwt.create_token(mod, claims, options)}
  end


  def build_claims(claims, resource, options) do
    {:ok, sub} = subject_for_token(resource, claims)
    build_claims(TokenModule, resource, sub, claims, options)
  end


  def build_claims(_mod, resource, sub, claims, _options) do

    {:ok, merge_claims(claims, sub, resource)}
  end


  def merge_claims(claims, sub, resource) do
    claims
    |> Map.merge(%{user: resource})
    |> Map.merge(%{iss: @config[:issuer]})
    |> Map.merge(%{sub: sub})
  end

end
