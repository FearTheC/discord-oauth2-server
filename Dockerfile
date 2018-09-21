FROM elixir:1.7.3-alpine AS builder
MAINTAINER Quentin Bonaventure <q.bonaventure@gmail.com>

WORKDIR /app

COPY . /app

ENV MIX_ENV=prod

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod && \
    mix release


FROM alpine

RUN apk --update --no-cache add openssl bash

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/discord_oauth2_server/ /app/

RUN ls /app

CMD ["bin/discord_oauth2_server", "foreground"]
