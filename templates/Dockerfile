ARG ELIXIR_VERSION=1.18.2
ARG OTP_VERSION=27.2.1
ARG DEBIAN_VERSION=bookworm-20250113

# https://hub.docker.com/r/hexpm/elixir/tags?name=debian-bookworm
FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}-slim

ARG HOST_UID=1000
ARG HOST_GID=1000

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  git curl build-essential inotify-tools libssl-dev nodejs npm \
  && rm -rf /var/lib/apt/lists/*

# Install Hex and Rebar
RUN mix local.hex --force && mix local.rebar --force

# Create a non-root user
RUN addgroup --system --gid ${HOST_GID} phoenix && \
    adduser --system --uid ${HOST_UID} --gid ${HOST_GID} --home /home/phoenix phoenix

# Set working directory
WORKDIR /app
RUN mkdir -p /app && chown -R phoenix:phoenix /app

# Ensure writable directories (for mix dependencies)
RUN mkdir -p /home/phoenix/.mix /home/phoenix/.hex && \
    chown -R phoenix:phoenix /home/phoenix/.mix /home/phoenix/.hex

# Switch to non-root user
USER phoenix

# Default command (interactive shell by default)
CMD ["/bin/bash"]
