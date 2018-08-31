FROM elixir:1.7.2

EXPOSE 4000
EXPOSE 8088
ENV PORT=4000 \
    MIX_ENV=prod

WORKDIR /app
COPY . .

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix deps.compile
RUN mix compile
RUN mix release --verbose --env=prod
COPY ./assets _build/prod/rel/emoji_server/assets

CMD _build/prod/rel/emoji_server/bin/emoji_server foreground