# https://hub.docker.com/r/hexpm/elixir/tags?name=debian-bookworm
FROM hexpm/elixir:1.15.7-erlang-26.1.1-debian-bookworm-20230612-slim

ARG HOST_USER_NAME
ARG HOST_GROUP_NAME
ARG HOST_UID
ARG HOST_GID
ARG HOST_UNAME

# install build dependencies
RUN apt-get update -y && apt-get install -y \
      build-essential \
      git \
      inotify-tools \
      nodejs \
      npm \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# sync user
RUN if [ "$HOST_UNAME" = "Darwin" ]; then \
      adduser --uid "$HOST_UID" --gid "$HOST_GID" "$HOST_USER_NAME"; \
    else \
      addgroup --gid "$HOST_GID" "$HOST_GROUP_NAME"; \
      adduser --uid "$HOST_UID" --gid "$HOST_GID" "$HOST_USER_NAME"; \
    fi

USER $HOST_USER_NAME

# install hex + rebar + phx_new
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new
