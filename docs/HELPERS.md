Helpers for developers
==

ToC
--

<!-- TOC -->

- [Helpers for developers](#helpers-for-developers)
    - [ToC](#toc)
    - [make vars](#make-vars)
    - [make ps](#make-ps)
    - [[NAME=ghost-local] make cli-version](#nameghost-local-make-cli-version)
    - [[NAME=ghost-local] make shell](#nameghost-local-make-shell)
    - [[NAME=ghost-local] make logs](#nameghost-local-make-logs)
    - [[NAME=ghost-local] make stop](#nameghost-local-make-stop)
    - [make pull](#make-pull)
    - [[NAME=ghost-local] make restart and make upgrades](#nameghost-local-make-restart-and-make-upgrades)

<!-- /TOC -->


## make vars

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

## make ps

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

## [NAME=ghost-local] make cli-version

Handy command to get Ghost and ghost-cli versions, plus the latest ghost version available on the Docker Hub. You will need python (2 or 3) installed to run this command, with the module requests (`pip install requests` or running your commands from a `pipenv shell`)

    $ make cli-version
    docker exec -it ghost-local ghost -v
    Ghost-CLI version: 1.7.3
    Ghost Version (at /var/lib/ghost): 1.23.0
    Latest version on Docker Hub: 1.23.0

## [NAME=ghost-local] make shell

It will connect to the running container, as the node user. That will allow you to run ghost-cli commands, or check out the configuration files

    $ make shell
    docker exec --user node -it ghost-local bash
    bash-4.3$

## [NAME=ghost-local] make logs

It will display (and follow) the logs

    $ make logs
    docker logs -f ghost-local
    [2018-05-23 06:02:21] INFO Finished database migration!
    [2018-05-23 06:02:23] WARN Theme's file locales/en.json not found.
    [2018-05-23 06:02:24] INFO Ghost is running in production...
    [2018-05-23 06:02:24] INFO Your blog is now available on http://localhost/ghost-local/
    [2018-05-23 06:02:24] INFO Ctrl+C to shut down
    [2018-05-23 06:02:24] INFO Ghost boot 2.043s

## [NAME=ghost-local] make stop

This will stop and delete the container with given NAME. Data is not lost though, thanks to the locally mounted volume

    $ make stop
    docker stop ghost-local
    ghost-local
    (ghost-in-a-shell-JYrXbwAb)

## make pull

Fetches the latest docker image (if necessary) from docker hub

    $ make pull
    docker pull ghost:1-alpine
    1-alpine: Pulling from library/ghost
    Digest: sha256:46b8d0e2437c46af0c2579a4a717a20c4253da2b75bb4dd4875b7686aaa9ca8d
    Status: Image is up to date for ghost:1-alpine

## [NAME=ghost-local] make restart and make upgrades

Those two commands are simple aliases defined for conveniency:

    restart: stop traefik logs

    upgrade: pull restart
