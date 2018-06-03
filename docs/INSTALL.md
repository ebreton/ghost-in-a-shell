<!-- markdownlint-disable MD034 -->
Installation and Usage
===

ToC
--

<!-- TOC -->

- [](#markdownlint-disable-md034)
    - [ToC](#toc)
    - [Pre-requisites](#pre-requisites)
        - [To run on a per-port basis](#to-run-on-a-per-port-basis)
        - [To run on a per-path basis](#to-run-on-a-per-path-basis)
    - [Setup](#setup)
        - [Default configuration](#default-configuration)
        - [Run on a per-port basis](#run-on-a-per-port-basis)
        - [Run on a per-path basis](#run-on-a-per-path-basis)
        - [HTTPs ?](#https)

<!-- /TOC -->

## Pre-requisites

### To run on a per-port basis

* [make](https://www.gnu.org/software/make/)
* [docker](https://www.docker.com/community-edition)
* python (2 or 3) with requests library (`pip install requests` or running your commands from a `pipenv shell`) if you want to have a few extended features, like `make cli-version` returning the latest ghost version available on docker hub.

That's it!

### To run on a per-path basis

Additionally to [make](https://www.gnu.org/software/make/) and [docker](https://www.docker.com/community-edition), you will need a running container of [traefik](https://traefik.io).

Feel free to use my companion repo, [prod-stack](https://github.com/ebreton/prod-stack). It will happily provide you with a pre-configured nginx+traefik proxy. You will need [docker-compose](https://docs.docker.com/compose/install/) to start it... and if you are not completely sure what it means, here is a [guide](./docs/VM_INSTALL.md) to setup a VM with everything you need (on CentOS for now)

## Setup

### Default configuration

Variables are defined in [.env](../.env) file, and can be modified in the command line when calling `make`. The file is self-documented, but here is a summary of the variables and default values:

Name | description | default | deployment where used
---------|----------|----------|---------
 NAME | for the container and the data folder (stored within _./instances_) | ghost-local | dev, qa, prod
 PROTOCOL | to build the URL | http | qa, prod (traefik)
 DOMAIN | to build the URL | localhost | dev, qa, prod
 PORT | to build the URL | 3001 | dev
 URI | to build the URL | ${NAME} | qa, prod (traefik)
 GHOST_VERSION | which docker image to use | 1 | dev, qa, prod. '-alpine' is added after the version number

### Run on a per-port basis

> The following variables will be used: NAME, DOMAIN, PORT, URI, GHOST_VERSION

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
2. through the logs (`make logs`)
3. by running `make ps`

        $ make ps
        # A lightly formatted version of docker ps
        docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}} ago'
        NAMES               IMAGE                           STATUS ago
        ghost-local         ghost:1-alpine                  Up About a minute ago

> Would you need another blog running on the side, you would define another couple of values for NAME and PORT. See next example to get a blog running  on <http://localhost:3002>

    NAME=another PORT=3002 make

> Another version ?

    GHOST_VERSION=1.11 NAME=old-buddy PORT=3003 make

### Run on a per-path basis

> The following variables will be used: NAME, PROTOCOL, DOMAIN, URI, GHOST_VERSION

The [prod-stack](https://github.com/ebreton/prod-stack) will actually offer you more than a proxy-combo: you will get what you could need in production (Nginx, MariaDB, and use of Let's Encrypt for HTTPs)

Once you have started your stack as indicated on [prod-stack](https://github.com/ebreton/prod-stack), you will just need to run `make qa` and head to <http://localhost/ghost-local>

    $ make qa
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

* `NAME=hello make qa` to get a fresh blog running on <http://localhost/hello>
* `GHOST_VERSION=0.10 NAME=bye make qa` to get another (old) blog running on <http://localhost/bye>
* and so on...

### HTTPs ?

The default configuration will set-up everything on HTTP. But the [prod-stack](https://github.com/ebreton/prod-stack) can to serve HTTPs (as well as support Let's Encrypt protocol, and force redirection from HTTP to HTTPs)

You only have to:

1. change the env var $PROTOCOL to https
1. make sure though that your $DOMAIN is accessible externaly

The second point is a MUST since traefik will get the certificate from Let's Encrypt, that will need access to your domain in return.
