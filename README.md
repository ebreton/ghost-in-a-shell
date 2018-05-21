# README #

This repository will provide you with an easy way to spaw ghost blogs (thanks to Docker)

1. either on your `localhost`, whatever environment you have
    * there, multiple ghosts will run on a **per-port basis**
2. or on any domain you own, whatever server you have
    * there, multiple ghosts will run on a **per-path basis**

## Pre-requisite

For the both solutions, you will need

* `make`
* `docker`

In the second case, you will need a running container of `traefik`. You can have a look at my other repo [prod-stack](https://github.com/ebreton/prod-stack) that will provide you with a reasonnable stack with the components that you will need in production (Nginx, MariaDB, and use of Let's Encrypt for HTTPs)

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

You will be able to check that everything went ok either through the logs, or by running `make ps-light`

    $ make ps-light
    # A lightly formatted version of docker ps
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}} ago'
    NAMES               IMAGE                           STATUS ago
    ghost-local         ghost:1-alpine                  Up About a minute ago

## Next steps

1. Facilitate definition of vars (.env ?)
1. Add command for HTTPs
