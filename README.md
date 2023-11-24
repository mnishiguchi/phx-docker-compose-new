# Elixir Phoenix Docker Compose generator

A [mix phx.new] wrapper that generates a new Phoenix app and basic development
environment with [Docker Compose] and [Livebook].

## Getting started

`phx-docker-compose-new` requires a few programs on your system.

- [Git] version control system
- [Docker] (Docker Engine and Docker CLI client)
- [Docker Compose]

```shell
git version
docker --version
docker compose version
```

You can download `phx-docker-compose-new` from Github.

```shell
git clone https://github.com/mnishiguchi/phx-docker-compose-new.git ~/.phx-docker-compose-new
```

Here is one way to make `phx-docker-compose-new` available in your terminal.

```shell
alias phx-docker-compose-new=~/.phx-docker-compose-new/phx-docker-compose-new.sh
```

Create a Phoenix app running `phx-docker-compose-new`. For possible options,
refer to [Phoenix documentation](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html).

```shell
phx-docker-compose-new sample_phx_app --no-assets --no-gettext --no-mailer
```

Change directory to your app and start Phoenix endpoint.

```shell
cd sample_phx_app

bin/start
```

Open the app from your browser:

* [localhost:4000/](http://localhost:4000) for your Phoenix application
* [localhost:4000/dev/dashboard/](http://localhost:4000/dev/dashboard) for [Phoenix LiveDashboard](https://hexdocs.pm/phoenix_live_dashboard)
* [localhost:4001/](http://localhost:4001) for [Livebook](https://livebook.dev/)

Here are some other commands:

- Stop Phoenix endpoint with `bin/stop`
- [IEx](https://elixirschool.com/en/lessons/basics/iex_helpers) into your running app with `bin/console`
- Check logs with `bin/logs`

[mix phx.new]: https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html
[Livebook]: https://livebook.dev/
[Docker Compose]: https://docs.docker.com/compose/
[Git]: https://git-scm.com/
[Docker]: https://docs.docker.com/engine/
[Docker Compose]: https://docs.docker.com/compose/
