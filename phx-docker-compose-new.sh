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

HOST_GID="$(id -g)"
HOST_GROUP_NAME="${USER}"
HOST_UID="$(id -u)"
HOST_UNAME="$(uname)"
HOST_USER_NAME="${USER}"

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

echo "SCRIPT_DIR:    $SCRIPT_DIR"
echo "APP_DIR:       $APP_DIR"
echo "APP_NAME:      $APP_NAME"
echo "APP_NODE_NAME: $APP_NODE_NAME"

## build image

IMAGE_NAME="phx-docker-compose-new"

docker build -t "$IMAGE_NAME" \
  --build-arg HOST_GID="$HOST_GID" \
  --build-arg HOST_GROUP_NAME="$HOST_GROUP_NAME" \
  --build-arg HOST_UID="$HOST_UID" \
  --build-arg HOST_UNAME="$HOST_UNAME" \
  --build-arg HOST_USER_NAME="$HOST_USER_NAME" \
  "$SCRIPT_DIR/templates"

## generate phoenix app

docker run \
  --rm \
  --mount type=bind,src="$CALLER_DIR",dst=/app \
  --workdir /app \
  "$IMAGE_NAME" \
  mix phx.new "$@"

## copy files from templates

cp "$SCRIPT_DIR/templates/Dockerfile" "$APP_DIR/"
cp "$SCRIPT_DIR/templates/docker-compose.yml" "$APP_DIR/"
cp -f "$SCRIPT_DIR/templates/README.md" "$APP_DIR/"
cp -r "$SCRIPT_DIR/templates/bin" "$APP_DIR/bin"

# dynamically generate bin/bootstrap because app name is fixed while other
# values are dependant on host machines
cat <<-EOF >"$APP_DIR/bin/bootstrap"
#!/bin/sh
set eu

APP_NAME="${APP_NAME}"
APP_NODE_NAME="${APP_NODE_NAME}"

gen_env() {
  {
    echo "export APP_COOKIE=\$(openssl rand -hex 12)"
    echo "export APP_NAME=\${APP_NAME}"
    echo "export APP_NODE_NAME=\${APP_NODE_NAME}"
    echo "export HOST_GID=\$(id -g)"
    echo "export HOST_GROUP_NAME=\${USER}"
    echo "export HOST_UID=\$(id -u)"
    echo "export HOST_UNAME=\$(uname)"
    echo "export HOST_USER_NAME=\${USER}"
  } >.env
}

if [ -f .env ]; then
  echo ".env already exists"
  printf "Overwrite (y/N)? "
  read -r option

  case "\$option" in
  y | Y)
    echo "yes"
    gen_env
    ;;
  *)
    echo "no"
    ;;
  esac
else
  gen_env
fi
EOF

## set up phoenix app

(
  cd "$APP_DIR"

  if command -v git >/dev/null; then
    git init
    git add .
    git commit -m "initial commit"
  fi

  # adjust phoenix config files so we can connect to app and db containers
  if [ "$HOST_UNAME" = "Darwin" ]; then
    sed -i '' 's/hostname: "localhost"/hostname: "db"/' ./config/dev.exs
    sed -i '' 's/hostname: "localhost"/hostname: "db"/' ./config/test.exs
    sed -i '' 's/ip: {127, 0, 0, 1}/ip: {0, 0, 0, 0}/' ./config/dev.exs
  else
    sed -i 's/hostname: "localhost"/hostname: "db"/' ./config/dev.exs
    sed -i 's/hostname: "localhost"/hostname: "db"/' ./config/test.exs
    sed -i 's/ip: {127, 0, 0, 1}/ip: {0, 0, 0, 0}/' ./config/dev.exs
  fi

  bin/bootstrap
  bin/setup
  bin/logs
  bin/test
  bin/stop
)

echo "
$APP_NAME has been successsfully generated at $APP_DIR 🎉

    $ cd $APP_NAME

Start your Phoenix app with:

    $ bin/start

Now you can open the app from your browser.

    $ open http://localhost:4000

"
