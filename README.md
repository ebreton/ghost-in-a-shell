<!-- markdownlint-disable -->
<h1 align="center" style="margin:1em">
  <img src="./docs/static/logo.png"
       alt="Ghost in A Shell"
       width="200">
    <br/> Ghost in A shell
</h1>

<h4 align="center">
  Spawn your ghost blogs fearlessly
  <br /> (thank you Docker!)
</h4>

<p align="center">
  <a href="https://github.com/ebreton/ghost-in-a-shell/blob/master/CHANGELOG.md">
    <img src="https://img.shields.io/github/release/ebreton/ghost-in-a-shell.svg"
         alt="Changelog">
  </a>
  <a href="https://github.com/ebreton/ghost-in-a-shell/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg"
         alt="License" />
  </a>
</p>
<br>

You just want to try Ghost without messing up your computer? (and that's why you already have docker installed)

> simply run `make` and head to <http://localhost:3001>

You want to play a bit more, and you would like to have multiple Ghosts on your domain / server?

* Either use *make* again and again with different variables, to get your blogs on a **per-port basis**
    > e.g.: `NAME=another PORT=3002 make` for a second blog on <http://localhost:3002>
* or leverage the power of [traefik](https://traefik.io) and have multiple ghosts on a **per-path basis** (see section below)
    > e.g.: `NAME=yet-another make traefik`. Head to <http://localhost/yet-another>

If you are worried with your data, be at rest: a local folder is created for every blog you create, named from $NAME variable. Stopping and restarting a blog with the same name will keep using the local data

ToC
--

<!-- TOC -->

- [Installation and usage](#installation-and-usage)
- [Helpers for developers](#helpers-for-developers)
    - [make vars](#make-vars)
    - [make ps](#make-ps)
    - [[NAME=ghost-local] make shell](#nameghost-local-make-shell)
    - [[NAME=ghost-local] make logs](#nameghost-local-make-logs)
    - [[NAME=ghost-local] make stop](#nameghost-local-make-stop)
- [Interested ?](#interested-)
    - [Look for what's coming next...](#look-for-whats-coming-next)
    - [Something is missing ?](#something-is-missing-)
- [Changelog](#changelog)
- [Contribution](#contribution)

<!-- /TOC -->

## Installation and usage

Installation is straightforward if you simply wish to export every container to a different port. `make` will do.

However, it is not really convenient if you wish to serve on standard ports (80 or 443) and if you want anyone to access your blog easily. In this case, you will need to setup traefik router, and run `make traefik`

You will find details and a step-by-step guide for both scenario in [INSTALL.md](./docs/INSTALL.md)

## Helpers for developers

Now that you have one (or more) blogs running, you might want to check their status, or access the containers...

A few helpers command are provided within the Makefile:

### make vars

It will list the values currently set of your environment variables

    $ make vars
    # values that will be used to create the blog URL
      NAME=ghost-local
      PROTOCOL=http
      DOMAIN=localhost
      PORT=3001
      URI=ghost-local

As with all other commands, you can override them either in [.env](./.env) file or through the command line:

    $ NAME=foo URI=bar PORT=3002 make vars
    # values that will be used to create the blog URL
      NAME=foo
      PROTOCOL=http
      DOMAIN=localhost
      PORT=3002
      URI=bar

More information on those variables can be found in [INSTALL.md](./docs/INSTALL.md#default-configuration)

### make ps

It will act as `docker ps`, displaying less columns

    $ make ps
    # A lightly formatted version of docker ps
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}} ago'
    NAMES               IMAGE                           STATUS ago
    ghost-local         ghost:1-alpine                  Up 4 minutes ago
    phpmyadmin          phpmyadmin/phpmyadmin           Up 2 days ago
    phpmemcacheadmin    jacksoncage/phpmemcachedadmin   Up 2 days ago
    db-shared           mariadb:latest                  Up 2 days ago
    nginx-entrypoint    nginx                           Up 2 days ago
    memcached           memcached                       Up 2 days ago
    traefik             traefik:latest                  Up 2 days ago

### [NAME=ghost-local] make shell

It will connect to the running container, as the node user. That will allow you to run ghost-cli commands, or check out the configuration files

    $ make shell
    docker exec --user node -it ghost-local bash
    bash-4.3$

### [NAME=ghost-local] make logs

It will display (and follow) the logs

    $ make logs
    docker logs -f ghost-local
    [2018-05-23 06:02:21] INFO Finished database migration!
    [2018-05-23 06:02:23] WARN Theme's file locales/en.json not found.
    [2018-05-23 06:02:24] INFO Ghost is running in production...
    [2018-05-23 06:02:24] INFO Your blog is now available on http://localhost/ghost-local/
    [2018-05-23 06:02:24] INFO Ctrl+C to shut down
    [2018-05-23 06:02:24] INFO Ghost boot 2.043s

### [NAME=ghost-local] make stop

This will stop and delete the container with given NAME. Data is not lost though, thanks to the locally mounted volume

    $ make stop
    docker stop ghost-local
    ghost-local
    (ghost-in-a-shell-JYrXbwAb)

## Interested ? 

### Look for what's coming next...

1. (/) Document HTTPs
1. (/) Authorize blog on raw domain (without named folder)
1. Make use of MariaDB and Nginx
1. Consolidate for production

### Something is missing ?

Head to [github issues](https://github.com/ebreton/ghost-in-a-shell/issues) and submit one! Be sure to have a look at the [CONTRIBUTING.md](./docs/CONTRIBUTING.md) guide before


## Changelog

All notable changes to this project are documented in [CHANGELOG.md](./CHANGELOG.md).

## Contribution

Check out [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for more details

As well as our [CODE_OF_CONDUCT.md](./docs/CODE_OF_CONDUCT.md), where we pledge to making participation in our project and our community a harassment-free experience for everyone
