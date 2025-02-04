#!/bin/bash

# Create a new Phoenix project using Docker

set -euo pipefail

# Colors for output formatting
BLUE="\033[34m"
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

# Utility functions for formatted output
echo_heading() { echo -e "\n${BLUE}$1${RESET}"; }
echo_success() { echo -e " ${GREEN}✔ $1${RESET}"; }
echo_failure() { echo -e " ${RED}✖ $1${RESET}"; }

# Display script usage information
show_help() {
  echo "
Creates a new Phoenix project inside a Docker environment.

Usage:
  $0 <project_name> [phx.new options]

The script wraps 'mix phx.new' and accepts all of its options.
For possible options, refer to the Phoenix documentation:
  https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html
"
}

# Ensure a project name is provided
if [ "$#" -eq 0 ]; then
  show_help
  exit 1
fi

# Check if Docker and Docker Compose are installed
echo_heading "Checking system dependencies..."
docker --version || {
  echo_failure "Docker is not installed. Please install Docker and try again."
  exit 1
}
docker compose version || {
  echo_failure "Docker Compose is not installed. Please install it and try again."
  exit 1
}

# Resolve real script path (even if symlinked)
SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Set project-related variables
APP_NAME="$(basename "$1")"
APP_NODE_NAME="$(echo "$APP_NAME" | tr _ -)"
APP_DIR="$(pwd)/$APP_NAME"

# Function to handle macOS and Linux sed differences
sed_i() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$1" "$2"
  else
    sed -i "$1" "$2"
  fi
}

echo_heading "Starting Phoenix project creation..."
echo "Script directory: $SCRIPT_DIR"
echo "Project directory: $APP_DIR"
echo "Application name: $APP_NAME"
echo "Application node name: $APP_NODE_NAME"

# Ensure the target project directory does not already exist
if [ -d "$APP_DIR" ]; then
  echo_failure "$APP_DIR already exists."
  printf "Overwrite (y/N)? "
  read -r option
  if [[ "$option" =~ ^[Yy]$ ]]; then
    rm -rf "$APP_DIR"
    echo_success "Removed existing project directory."
  else
    echo_failure "Please select another directory for installation."
    exit 1
  fi
fi

# Generate Phoenix project inside Docker
echo_heading "Generating Phoenix project using Docker..."
ELIXIR_VERSION="1.18.2"
OTP_VERSION="27.2.1"
ALPINE_VERSION="3.20.5"

# Docker run options:
# - `--rm` → Remove the container after execution to keep things clean.
# - `--mount type=bind,source="$(pwd)",target=/app` → Mounts the current directory to `/app`.
# - `-w /app` → Sets `/app` as the working directory.
# - `-u "$(id -u):$(id -g)"` → Runs as the host user to avoid root-owned files.
# - `-e MIX_HOME=/tmp/.mix -e HEX_HOME=/tmp/.hex` → Use temporary directories for Mix/Hex to prevent permission issues.
set -x
docker run \
  --rm \
  --mount type=bind,source="$(pwd)",target=/app \
  -w /app \
  -u "$(id -u):$(id -g)" \
  -e MIX_HOME=/tmp/.mix \
  -e HEX_HOME=/tmp/.hex \
  "hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}" \
  sh -c "
    mix local.hex --force &&
    mix archive.install hex phx_new --force &&
    mix phx.new $APP_NAME
  "
set +x
echo_success "Phoenix project created successfully."

(
  cd "$APP_DIR"

  echo_heading "Configuring Docker setup..."
  set -x
  cp "$SCRIPT_DIR/templates/Dockerfile" "$APP_DIR/Dockerfile"
  cp "$SCRIPT_DIR/templates/docker-compose.yml" "$APP_DIR/docker-compose.yml"
  set +x

  echo_heading "Setting up bin/ commands..."
  set -x
  mkdir -p bin
  cp -r "$SCRIPT_DIR/templates/bin/"* bin/
  chmod +x bin/*
  set +x

  echo_heading "Updating configuration files..."
  set -x
  sed_i 's/hostname: "localhost"/hostname: "db"/' ./config/dev.exs
  sed_i 's/hostname: "localhost"/hostname: "db"/' ./config/test.exs
  sed_i 's/ip: {127, 0, 0, 1}/ip: {0, 0, 0, 0}/' ./config/dev.exs
  set +x

  echo_heading "Creating environment file..."
  cat <<EOF >.env
# User and Group IDs for file ownership inside the container
HOST_UID=$(id -u)
HOST_GID=$(id -g)

# Phoenix application configuration
export APP_NODE_NAME=$APP_NODE_NAME
export APP_COOKIE=securesecret
EOF
  cat .env
  echo_success ".env file created successfully."

  echo_heading "Running initial setup..."
  bin/setup
  bin/test
  bin/stop
)

cat <<EOF

Phoenix project '$APP_NAME' has been successfully created! 🎉🎉🎉

Next Steps:
  1️⃣ Change into your project directory:
      cd $APP_NAME

  2️⃣ Start your Phoenix application:
      docker compose up

  3️⃣ Open your app in the browser:
      ▶ Phoenix App: http://localhost:4000/
      ▶ Phoenix LiveDashboard: http://localhost:4000/dev/dashboard/
      ▶ Livebook: http://localhost:8080/

     (For advanced use, Livebook's runtime is attached to '${APP_NODE_NAME}@web')

  4️⃣ Stop the application when done:
      docker compose down

Enjoy coding with Phoenix! 🚀
EOF
