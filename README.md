# DiscordOauth2Server

Elixir server using [Discord OAuth2](https://discordapp.com/developers/docs/topics/oauth2) service and an existing database to provide JWS token.

<img src="https://docs.fearthec.io/images/ftc-logo.png" alt="Fear The C{ode}" width="400">

It acts as a proxy. From the client side, simply redirects to the `/login` endpoint, which will then 

![Discord OAuth2 Server - Sequence Diagram](https://lh6.googleusercontent.com/rPQ6P923f9QovYJ4b0k_HAKPEuMoH76tGkBEam3Zm3hkZZ6Srj1F4LaE-dVm1Ier4nP0X-Y1C2pmSg=w1383-h655)

## Dependencies

### Elixir platform
- Elixir 1.7.3
- Erlang/OTP 21

### Supported Databases
Only PostgreSQL with [Postgrex](https://github.com/elixir-ecto/postgrex) is supported at this time, as no abstractions has been implemented (yet) to easily swap between DBs and drivers.

### Supported encryption

As of now, the server provides ECDSA-like signed JWS. A little more development may be necessary to support more algorithms.

## Quick Start


## Exemples

### /ping
```json
{
  "status": "ok",
  "timestamp": "1537360546"
}
```

### /public_keys
```json
{
  "keys": {
    "crv": "P-521",
    "kty": "EC",
    "x": "ABeULuyYwEDVAkJtgNvgeG0v6rNtKDOYkKUMqjJyR-aCfjbkPpsl2MZXVdsjNR31oGbCB4gT5qpgjiXgqqqT5BRC",
    "y": "AdDA3RxRlGzy0chCTKaWQffWx9xBDrOPKf_TgpzlfdJw9QykNCguvAQeE7ZrzwPcAziRAQcVmorzPpGioR96VsY6"
  },
  "status": "ok"
}
```

![FTC Bot system diagram](https://docs.fearthec.io/images/ftc-bot-system.png)
