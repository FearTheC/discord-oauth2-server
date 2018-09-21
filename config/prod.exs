use Mix.Config

config :discord_oauth2_server,
  client_id: System.get_env("DISCORD_CLIENT_ID"),
  client_secret: System.get_env("DISCORD_CLIENT_SECRET"),
  redirect_uri: ""

config :discord_oauth2_server, db: [
  pool: DBConnection.Poolboy,
  pool_size: 10,
  database: System.get_env("DB_NAME"),
  types: DiscordOauth2Server.PostgrexTypes,
  hostname: System.get_env("DB_HOSTNAME"),
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD")
]

config :discord_oauth2_server, DiscordOauth2Server.TokenModule,
  allowed_algos: ["ES512"],
  verify_module: Guardian.JWT,
  issuer: System.get_env("DISCORD_OAUTH_TOKEN_ISSUER"),
  ttl: { 1, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: %{
    "crv" => "P-521",
    "d" => System.get_env("DISCORD_OAUTH_TOKEN_SECRET_KEY"),
    "kty" => "EC",
    "x" => "AJEj-12C0KHWj4Vx97X8c2g9fc7hIGPeagYUimZSTiEGt1k0tDGVw5lJoExheDumHyVafqiSdgUfKcjthwMYtBeT",
    "y" => "AF_iCMF7DxAetOw_ZV5_Gi1FpH7gPdicxkphpyr5AXbbKnINnSl9E50CQQr2cFHxHwQ5bCitAFt8n6ueGFn1xk3Y"
  }

import_config "prod.secret.exs"
