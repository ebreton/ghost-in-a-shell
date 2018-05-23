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
- [Interested ?](#interested-)
    - [Look for what's coming next...](#look-for-whats-coming-next)
    - [Something is missing ?](#something-is-missing-)
- [Changelog](#changelog)
- [Contribution](#contribution)

<!-- /TOC -->

## Overview

You just want to try Ghost without messing up your computer? (and that's why you already have docker installed)

> simply run `make` and head to <http://localhost:3001>

You want to play a bit more, and you would like to have multiple Ghosts on your domain / server?

* Either use *make* again and again with different variables, to get your blogs on a **per-port basis**
    > e.g.: `NAME=another PORT=3002 make` for a second blog on <http://localhost:3002>
* or leverage the power of [traefik](https://traefik.io) and have multiple ghosts on a **per-path basis** (see section below)
    > e.g.: `NAME=yet-another make traefik`. Head to <http://localhost/yet-another>

If you are worried with your data, be at rest: a local folder is created for every blog you create, named from $NAME variable. Stopping and restarting a blog with the same name will keep using the local data

## Installation and usage

Installation is straightforward if you simply wish to bridge to a container port (3001 by default). `make` will do.

However, it is not really convenient if you wish to serve on standard ports (80 or 443) and if you want anyone to access your blog easily. In this case, you will need to setup traefik router, and run `make traefik`

You will find details and a step-by-step guide for both scenario in [INSTALL.md](./docs/INSTALL.md)

## Helpers for developers

Now that you have one (or more) blogs running, you might want to check their status, or access the containers...

A few helpers are provided within the Makefile:

Command | Description | Variables
---------|----------|---------
 `make vars` | Display the values of all env vars | All
 `make ps` | Display the running containers | None
 `make shell` | Connect to given Ghost container | NAME
 `make logs` | Tail and follow the logs of given Ghost container | NAME
 `make stop` | Stop given Ghost container | NAME

More detailed can be found in [HELPERS.md](./docs/HELPERS.md)

## Interested ? 

### Look for what's coming next...

1. Make use of MariaDB and Nginx
1. Consolidate for production

### Something is missing ?

Head to [github issues](https://github.com/ebreton/ghost-in-a-shell/issues) and submit one! Be sure to have a look at the [CONTRIBUTING.md](./docs/CONTRIBUTING.md) guide before


## Changelog

All notable changes to this project are documented in [CHANGELOG.md](./CHANGELOG.md).

## Contribution

Check out [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for more details

As well as our [CODE_OF_CONDUCT.md](./docs/CODE_OF_CONDUCT.md), where we pledge to making participation in our project and our community a harassment-free experience for everyone
