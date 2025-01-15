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

### Generate a New Phoenix Project

Use `phxd-new` to create a new Phoenix project:

```sh
phxd-new my_app
```

This command:

- Generates a Phoenix application in `my_app/`.
- Sets up a Docker-based development environment.
- Copies useful `bin/` scripts for common tasks.

## Livebook Integration

A Livebook instance is included and attached to the Phoenix app node. You can access it at:

- **Livebook**: [http://localhost:8080](http://localhost:8080)
- **Phoenix App**: [http://localhost:4000](http://localhost:4000)
- **LiveDashboard**: [http://localhost:4000/dev/dashboard](http://localhost:4000/dev/dashboard)

To ensure Livebook works correctly, the runtime is attached as:

```yaml
LIVEBOOK_DEFAULT_RUNTIME=attached:${APP_NODE_NAME}@web:${APP_COOKIE}
```

## Start Developing

Your Phoenix application is now ready to run inside a Docker container. Enjoy coding!
