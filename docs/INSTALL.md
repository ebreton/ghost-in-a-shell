<!-- markdownlint-disable MD034 -->
Installation and Usage
===

ToC
--

<!-- TOC -->

- [Pre-requisites](#pre-requisites)
    - [per-port basis](#per-port-basis)
    - [per-path basis](#per-path-basis)
- [Setup](#setup)
    - [per-port basis](#per-port-basis-1)
    - [per-path basis](#per-path-basis-1)

<!-- /TOC -->

## Pre-requisites

### per-port basis

* [make](https://www.gnu.org/software/make/)
* [docker](https://www.docker.com/community-edition)

That's it!

### per-path basis

Additionally to [make](https://www.gnu.org/software/make/) and [docker](https://www.docker.com/community-edition), you will need a running container of [traefik](https://traefik.io).

Feel free to use my companion repo, [prod-stack](https://github.com/ebreton/prod-stack). It will happily provide you with a pre-configured nginx+traefik proxy. You will need [docker-compose](https://docs.docker.com/compose/install/) to start it... and if you are not completely sure what it means, here is a [guide](./docs/VM_INSTALL.md) to setup a VM with everything you need (on CentOS for now)

## Setup

### per-port basis

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

You will be able to check that everything went ok 

1. on <http://localhost:3001>,
2. through the logs, or
3. by running `make ps-light`

        $ make ps-light
        # A lightly formatted version of docker ps
        docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}} ago'
        NAMES               IMAGE                           STATUS ago
        ghost-local         ghost:1-alpine                  Up About a minute ago

> Would you need another blog running on the side, you would define another couple of values for NAME and PORT. See next example to get a blog running  on <http://localhost:3002>

    NAME=another PORT=3002 make

### per-path basis

The [prod-stack](https://github.com/ebreton/prod-stack) will actually offer you more than a proxy-combo: you will get what you could need in production (Nginx, MariaDB, and use of Let's Encrypt for HTTPs)

Once you have started your stack as indicated on [prod-stack](https://github.com/ebreton/prod-stack), you will just need to run `make traefik` and head to <http://localhost/ghost-local>

    $ make traefik
    # Start a ghost container behind traefik (therefore available through 80 or 443), on path $NAME
    # Beware of --network used, which is the same one traefik should be using
    docker run --rm -d --name ghost-local \
            -v /Users/emb/Documents/git-repos/ghost-in-a-shell/ghost-local:/var/lib/ghost/content \
            -e url=http://localhost/ghost-local \
            --network=proxy \
            --label "traefik.enable=true" \
            --label "traefik.backend=ghost-local" \
            --label "traefik.frontend.entryPoints=http" \
            --label "traefik.frontend.rule=Host:localhost;PathPrefix:/ghost-local" \
            ghost:1-alpine
    f9132231535e12ccdec0da2534c03043b16ffd88cba91f44b76f2d71e115f872

If you have already launched a container with the default environment variables, you will need to define another NAME:

* `NAME=hello make traefik` to get a fresh blog running on <http://localhost/hello>
* `NAME=bye make traefik` to get another blog running on <http://localhost/bye>
* and so on...
