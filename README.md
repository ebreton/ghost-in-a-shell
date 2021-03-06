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

ToC
--

<!-- TOC -->

- [Overview](#overview)
- [Installation and usage](#installation-and-usage)
- [Helpers for developers](#helpers-for-developers)
- [Production](#production)
- [Something is missing ?](#something-is-missing-)
- [Changelog](#changelog)
- [:warning: Backward incompatible changes](#warning-backward-incompatible-changes)
- [Contribution](#contribution)

<!-- /TOC -->

## Overview

You just want to try Ghost without messing up your computer? (and that's why you already have docker installed)

> simply run `make` and head to <http://localhost:3001>

You want to play a bit more, and you would like to have multiple Ghosts on your domain / server?

* Either use *make* again and again with different variables, to get your blogs on a **per-port basis**
    > e.g.: `NAME=another PORT=3002 make` for a second blog on <http://localhost:3002>
* or leverage the power of [traefik](https://traefik.io) and have multiple ghosts on a **per-path basis** (see section below)
    > e.g.: `NAME=yet-another make qa`. Head to <http://localhost/yet-another>

By the way, you would like to run an old version of Ghost ? `GHOST_VERSION=x.x.x make qa` will do this for you. You can use whatever version is available on [docker hub](https://hub.docker.com/_/ghost)

If you are worried with your data, be at rest: a local folder is created within path _./instances_, for every blog you create, named from $NAME variable. Stopping and restarting a blog with the same name will keep using the local data.

## Installation and usage

Command | Description | Remarks
---------|----------|---------
 `make` | straightforward (local) installation if you simply wish to bridge a container port on your host (3001 by default) | also known as `make dev`
 `make qa` | The former being not really convenient if you wish to serve on standard ports (80 or 443), and if you want anyone to access your blog easily, this command sets up a traefik router | recommended usage of [prod-stack](https://github.com/ebreton/prod-stack)
 <code>make&nbsp;prod</code> | Same as above, using a MariaDB instead of SQLite and an email provider (Mailgun) | requires a (free) account at Mailgun

You will find details and a step-by-step guide for both scenario in [INSTALL.md](./docs/INSTALL.md)

If you'd rather have a **Tutorial** than a raw INSTALL.md file, feel free to check my "_Ghost in A shell_" series:
1. [Part I : localhost](https://dev.to/ebreton/ghost-in-a-shell---part-i--localhost-5he9)
1. [Part II : HTTPs is the norm](https://dev.to/ebreton/ghost-in-a-shell---part-ii---https-is-the-norm-1jj4)
1. [Part III - To Production, with performance](https://dev.to/ebreton/ghost-in-a-shell---part-iii--to-production-with-performance-10g5)
2. [Part IV - Maintenance](https://dev.to/ebreton/ghost-in-a-shell---part-iv-and-final-maintenance-2a5p)

## Helpers for developers

Now that you have one (or more) blogs running, you might want to check their status, or access the containers...

A few helpers are provided within the Makefile:

Command | Description | Variables
---------|----------|---------
 `make vars` | Display the values of all env vars | All
 `make ps` | Display the running containers | None
 `make cli-version` | Display Ghost & ghost-cli version, + latest version available on docker hub | NAME
 `make shell` | Connect to given Ghost container | NAME
 `make logs` | Tail and follow the logs of given Ghost container | NAME
 `make stop` | Stop given Ghost container | NAME
 `make pull` | Update docker image from dockerhub | None
 `make restart` | Calls `make stop qa logs` | NAME (and from `make qa`: PROTOCOL, DOMAIN, URI)
 `make upgrade` | Calls `make pull restart` | same as above
 <code>make&nbsp;gatling&nbsp;&nbsp;&nbsp;&nbsp;</code> | Execute load tests | GATLING_BASE_URL, GATLING_USERS, GATLING_RAMP


More detailed can be found in [HELPERS.md](./docs/HELPERS.md)

## Production

Environment variables are defined in ./etc/prod.env, e.g:
- MYSQL_ROOT_PASSWORD
- MAILGUN_LOGIN
- MAILGUN_PASSWORD

Command | Description 
---------|----------
 <code>make&nbsp;prod&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</code> | Runs Ghost behind a proxy (Nginx+Traefik), on HTTPs, with a (Maria)DB and Mailgun email provider
 `make restart-prod` | Calls `make stop prod logs`
 `make upgrade-prod` | Calls `make pull restart-prod`


## Something is missing ?

Head to [github issues](https://github.com/ebreton/ghost-in-a-shell/issues) and submit one! Be sure to have a look at the [CONTRIBUTING.md](./docs/CONTRIBUTING.md) guide before


## Changelog

All notable changes to this project are documented in [CHANGELOG.md](./CHANGELOG.md).

## :warning: Backward incompatible changes

- :boom: v0.2.0 : data volumes are now created within subfolder ./instances. You will need to move your data from the root folder into this new place
- :alarm_clock: v0.4.0: `make traefik` replaced with `make qa` instead

## Contribution

Check out [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for more details

As well as our [CODE_OF_CONDUCT.md](./docs/CODE_OF_CONDUCT.md), where we pledge to making participation in our project and our community a harassment-free experience for everyone
