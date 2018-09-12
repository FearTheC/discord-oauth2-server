FROM elixir:alpine

WORKDIR /app

COPY . /app

RUN export MIX_ENV=development && \
    rm -Rf _build && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get
