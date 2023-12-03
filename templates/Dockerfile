# https://hub.docker.com/r/hexpm/elixir/tags?name=debian-bookworm
FROM hexpm/elixir:1.15.7-erlang-26.1.1-debian-bookworm-20230612-slim

ARG GID
ARG UID
ARG UNAME
ARG USER

# install build dependencies
RUN apt-get update -y && apt-get install -y \
      build-essential \
      git \
      inotify-tools \
      nodejs \
      npm \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# sync user
RUN if [ "$UNAME" = "Darwin" ]; then \
      adduser --uid "$UID" --gid "$GID" "$USER"; \
    else \
      addgroup --gid "$GID" "$USER"; \
      adduser --uid "$UID" --gid "$GID" "$USER"; \
    fi

USER $USER

# install hex + rebar + phx_new
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new
