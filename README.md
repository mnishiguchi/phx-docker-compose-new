# phx-dock: Run Phoenix in Docker

## Introduction

`phx-dock` provides a simple way to set up a Phoenix development environment
inside a Docker container without installing Elixir or Phoenix on your local
machine.

## Installation

To install `phxd-new`, run:

```sh
curl -fsSL https://raw.githubusercontent.com/mnishiguchi/phx-dock/main/install.sh | bash
```

This will:

- Clone the repository into `~/.config/phx-dock`.
- Create a symlink `~/.local/bin/phxd-new` for easy access.

After installation, you can run `phxd-new` from anywhere.

## Creating a Phoenix App Using `phxd-new`

Use `phxd-new` to create a new Phoenix project:

```sh
phxd-new my_app
```

This command:

- Generates a Phoenix application in `my_app/`.
- Sets up a Docker-based development environment.
- Copies useful `bin/` scripts for common tasks.

## Running your Phoenix App in Docker

After generating your Phoenix project with `phxd-new`, you can start your
development environment using Docker.

Navigate into your project directory:

```sh
cd my_app
```

Then, start the application:

```sh
docker compose up
```

Your Phoenix app will be available at: http://localhost:4000

## Using Livebook

If you want to use Livebook, it's already included in the setup. You can access
it at: http://localhost:8080

This allows you to run interactive notebooks connected to your Phoenix app.
