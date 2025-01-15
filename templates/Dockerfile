ARG ELIXIR_VERSION=1.18.2
ARG OTP_VERSION=27.2.1
ARG DEBIAN_VERSION=bookworm-20250113

# https://hub.docker.com/r/hexpm/elixir/tags?name=debian-bookworm
FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  git curl build-essential inotify-tools libssl-dev nodejs npm \
  && rm -rf /var/lib/apt/lists/*

# Install Hex and Rebar (Elixir package managers)
RUN mix local.hex --force && mix local.rebar --force

# Configure Mix directories for a writable setup
ENV MIX_HOME="/home/phoenix/.mix"
RUN mkdir -p $MIX_HOME /home/phoenix/.hex/packages/hexpm /home/phoenix/tmp \
    && chmod -R 777 $MIX_HOME /home/phoenix/.hex /home/phoenix/tmp /tmp

# Install Phoenix globally
RUN mix archive.install hex phx_new --force

# Create a non-root user
RUN addgroup --system phoenix && adduser --system --ingroup phoenix --home /home/phoenix phoenix

# Ensure UID/GID mapping works when using -u $(id -u):$(id -g)
RUN echo "phoenix:x:1000:1000::/home/phoenix:/bin/bash" >> /etc/passwd && \
    echo "phoenix:x:1000:" >> /etc/group

# Ensure /tmp is writable
ENV TMPDIR="/home/phoenix/tmp"

# Set working directory
WORKDIR /app
RUN mkdir -p /app && chown -R phoenix:phoenix /app

# Switch to non-root user
USER phoenix

# Default command (interactive shell by default)
CMD ["/bin/bash"]
