defmodule DiscordOauth2Server.Database do

  alias DiscordOauth2Server.User

  @get_guild_user_query """
SELECT users.id, users.username, users.tag, users.email,
array_to_json(array_agg((SELECT row_to_json(_) FROM (SELECT roles.role_id, guilds_roles.name, guilds_roles.permissions) as _))) as roles
FROM users
JOIN guilds_domains domains ON domains.domain = $2
JOIN guilds_roles ON guilds_roles.guild_id = domains.guild_id
JOIN members_roles roles ON roles.user_id = users.id AND guilds_roles.id = roles.role_id
WHERE users.id = $1
GROUP BY users.id, users.username, users.tag, users.email
"""

  def fetch_guild_user(user_id, guild_domain) do
    %Postgrex.Result{columns: columns, rows: [user | _]}  = Postgrex.query!(DB, @get_guild_user_query, [user_id, guild_domain], [pool: DBConnection.Poolboy])
    to_user columns, user
  end

  def get_user(_id) do

  end

  def to_user(columns, user) do
    row = Enum.zip(columns, user) |> Enum.into(%{})
    %User{
      id: row["id"],
      username: row["username"],
      tag: row["tag"],
      email: row["email"],
      roles: row["roles"]
    }
  end

end
