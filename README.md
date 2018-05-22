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
  <a href="https://github.com/ebreton/ghost-in-a-shell/blob/master/docs/CHANGELOG.md">
    <img src="https://img.shields.io/github/release/ebreton/ghost-in-a-shell.svg"
         alt="Changelog">
  </a>
  <a href="https://github.com/ebreton/ghost-in-a-shell/blob/master/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg"
         alt="License" />
  </a>
</p>
<br>

You just want to try Ghost without messing up your computer ? (and that's why you already have docker installed)

> simply run `make` and head for <http://localhost:3001>

You want to play a bit more, and you would like to have multiple Ghosts on your domain / server ?

* Either use `make` again and again with different variables, to get your blogs on a **per-port basis**, 
* or leverage the power of [traefik](https://traefik.io) power and have multiple ghosts on a **per-path basis**

> in the later case, use the [prod-stack](https://github.com/ebreton/prod-stack) companion and `make traefik`. Head for <http://localhost/ghost-local>

Summary
--

<!-- TOC -->

- [Pre-requisite](#pre-requisite)
    - [per-port basis](#per-port-basis)
    - [per-path basis](#per-path-basis)
- [Setup](#setup)
- [Interested ? Look for what's coming...](#interested--look-for-whats-coming)
- [Something is missing ?](#something-is-missing-)
- [Changelog](#changelog)
- [Contribution](#contribution)

<!-- /TOC -->

## Pre-requisite 

### per-port basis

* `make`
* [docker](https://www.docker.com/community-edition)

That's it !

### per-path basis

Additionnaly to `make` and [docker](https://www.docker.com/community-edition), you will need a running container of [traefik](https://traefik.io).

Feel free to use my companion repo, [prod-stack](https://github.com/ebreton/prod-stack). It will happily provide you with a pre-configured nginx+traefik proxy. You will need [docker-compose](https://docs.docker.com/compose/install/) additionnaly to docker. And if you are not completely sure what it means, here is a [guide](./docs/VM_INSTALL.md) to setup a VM with everything you need

The [prod-stack](https://github.com/ebreton/prod-stack) will actually offer you more than a proxy-combo: you will get what you could need in production (Nginx, MariaDB, and use of Let's Encrypt for HTTPs)

> but they are not yet used in this version of Ghost-in-a-shell. More to come :)

## Setup

To get everything running, what could be better than one line?

-> A one-word single line: `make`

    $ make
    # Simply start a ghost container making it directly available through $PORT
    docker run --rm -d --name ghost-local \
        -v /Users/emb/Documents/git-repos/ghost-in-a-shell/ghost-local:/var/lib/ghost/content \
        -p 3001:2368 \
        -e url=http://localhost:3001 \
        ghost:1-alpine
    c13be64808bb44e58ba41afc158f8756efa71d613158333225dc12e2c2bcdb36

You will be able to check that everything went ok 1) on <http://localhost:3001>, 2) through the logs, or 3) by running `make ps-light`

    $ make ps-light
    # A lightly formatted version of docker ps
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}} ago'
    NAMES               IMAGE                           STATUS ago
    ghost-local         ghost:1-alpine                  Up About a minute ago

## Interested ? Look for what's coming...

1. Facilitate definition of vars
1. Add commands for HTTPs

## Something is missing ?

Head to [github issues](https://github.com/ebreton/ghost-in-a-shell/issues) and submit one ! Be sure to have a look at the [CONTRIBUTING.md](./docs/CONTRIBUTING.md) guide before


## Changelog

All notable changes to this project are documented in [CHANGELOG.md](./CHANGELOG.md).

## Contribution

Check out [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for more details

As well as our [CODE_OF_CONDUCT.md](./docs/CODE_OF_CONDUCT.md), where we pledge to making participation in our project and our community a harassment-free experience for everyone
