# https://hub.docker.com/r/hexpm/elixir/tags?name=debian-bookworm
FROM hexpm/elixir:1.15.7-erlang-26.1.1-debian-bookworm-20230612-slim

ARG GID
ARG UID
ARG UNAME
ARG USER

RUN set -x && apt-get update --yes && apt-get install --yes --no-install-recommends \
      build-essential \
      git \
      inotify-tools \
      nodejs \
      npm \
    && apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/*

RUN if [ "$UNAME" = "Darwin" ]; then \
      adduser --uid "$UID" --gid "$GID" "$USER"; \
    else \
      addgroup --gid "$GID" "$USER"; \
      adduser --uid "$UID" --gid "$GID" "$USER"; \
    fi

USER $USER

RUN mix local.hex --force && mix local.rebar --force


