#!/bin/sh
#
# Creates a new Phoenix project and development environment with Docker Compose.
#
# It expects the path of the project as an argument.
#
#     $ mix-docker-compose-new PATH [--module MODULE] [--app APP]
#
# For possible options, see Phoenix documentation at https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html
#
set -eu

if echo "$*" | grep -q "verbose"; then
  set -x
fi

## validation

# ensure that arguments are provided
if [ $# -eq 0 ]; then
  echo '
Creates a new Phoenix project.

It expects the path of the project as an argument.

    $ mix-docker-compose-new PATH [--module MODULE] [--app APP]

A project at the given PATH will be created. The application name and module
name will be retrieved from the path, unless --module or --app is given.
'
  exit 1
fi

# docker and docker compose are required
docker --version
docker compose version

## calculate necessary values

APP_NAME="$(basename "$1")"

# underscores aren't valid characters in DNS hostnames
APP_NODE_NAME="$(echo "$APP_NAME" | tr _ -)"

## check paths

CALLER_DIR="$(pwd)"

SCRIPT_DIR="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

# ensure that app directory is an absolute path
case "$1" in
/*)
  # already absolute path
  APP_DIR="$1"
  ;;
*)
  APP_DIR="$CALLER_DIR/$APP_NAME"
  ;;
esac

if [ -d "$APP_DIR" ]; then
  echo "$APP_DIR already exists."
  printf "Overwrite (y/N)? "
  read -r option

  case "$option" in
  y | Y)
    rm -rf "$APP_DIR"
    ;;
  *)
    echo "Please select another directory for installation."
    exit 1
    ;;
  esac
fi

echo "SCRIPT_DIR:    $SCRIPT_DIR"
echo "APP_DIR:       $APP_DIR"
echo "APP_NAME:      $APP_NAME"
echo "APP_NODE_NAME: $APP_NODE_NAME"

## build image

IMAGE_NAME="phx-docker-compose-new"

docker build -t "$IMAGE_NAME" \
  --build-arg GID="$(id -g)" \
  --build-arg UID="$(id -u)" \
  --build-arg UNAME="$(uname)" \
  --build-arg USER="$USER" \
  "$SCRIPT_DIR/templates"

## generate phoenix app

docker run \
  --rm \
  --mount type=bind,source="$CALLER_DIR",target=/app \
  --workdir /app \
  "$IMAGE_NAME" \
  mix phx.new "$@"

## set up phoenix app

sed_i() {
  if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "$1" "$2"
  else
    sed -i "$1" "$2"
  fi
}

(
  cd "$APP_DIR"

  # copy files from templates
  cp "$SCRIPT_DIR/templates/Dockerfile" .
  cp "$SCRIPT_DIR/templates/docker-compose.yml" .
  cp -f "$SCRIPT_DIR/templates/README.md" .
  cp -r "$SCRIPT_DIR/templates/bin" ./bin

  # app name and node name are determined based on the user input
  sed_i "s/__DECLARE_APP_NAME__/$APP_NAME/" ./bin/bootstrap
  sed_i "s/__DECLARE_APP_NODE_NAME__/$APP_NODE_NAME/" ./bin/bootstrap

  # prepare .gitignore
  echo ".env*" >>.gitignore

  # make a git commit with default phoenix app
  if command -v git >/dev/null; then
    git init
    git add .
    git commit -m "initial commit"
  fi

  # adjust phoenix config files so we can connect to app and db containers
  sed_i 's/hostname: "localhost"/hostname: "db"/' ./config/dev.exs
  sed_i 's/hostname: "localhost"/hostname: "db"/' ./config/test.exs
  sed_i 's/ip: {127, 0, 0, 1}/ip: {0, 0, 0, 0}/' ./config/dev.exs

  # run commands
  bin/bootstrap
  bin/setup
  bin/logs
  bin/test
  bin/stop
)

echo "
$APP_NAME has been successsfully generated at $APP_DIR 🎉🎉🎉

    $ cd $APP_NAME


Load environment variables with:

    $ . ./.env

Start your Phoenix app with:

    $ bin/start

Open your Phoenix app from a browser at:

    http://localhost:4000/

Open Phoenix LiveDashboard at:

    http://localhost:4000/dev/dashboard/

Open Livebook at:

    http://localhost:8080/

"
