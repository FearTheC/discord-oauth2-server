FROM elixir:1.7.3-alpine

WORKDIR /app

COPY . /app

RUN export MIX_ENV=dev && \
    rm -Rf _build && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get
