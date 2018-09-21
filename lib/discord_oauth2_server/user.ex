defmodule DiscordOauth2Server.User do

  @derive {Jason.Encoder, only: [:id, :username, :tag, :email, :roles]}

  defstruct id: nil, username: nil, tag: nil, email: nil, roles: nil

end
