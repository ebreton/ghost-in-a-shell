#!make
# Default values, can be overridden either on the command line of make
# or in .env

.PHONY: dev traefik vars \
	cli-version ps shell logs stop pull \
	app-version release push-qa push-prod update-changelog 

VERSION:=$(shell python update_release.py -v)

dev: check-env
	# Simply start a ghost container making it directly available through $$PORT
	docker run --rm -d --name ${NAME} \
		-v $(shell pwd)/${NAME}:/var/lib/ghost/content \
		-p ${PORT}:2368 \
		-e url=http://${DOMAIN}:${PORT} \
		ghost:1-alpine

traefik: check-env
	# Start a ghost container behind traefik (therefore available through 80 or 443), on path $$NAME
	# Beware of --network used, which is the same one traefik should be using
	docker run --rm -d --name ${NAME} \
		-v $(shell pwd)/${NAME}:/var/lib/ghost/content \
		-e url=${PROTOCOL}://${DOMAIN}/${URI} \
		--network=proxy \
		--label "traefik.enable=true" \
		--label "traefik.backend=${NAME}" \
		--label "traefik.frontend.entryPoints=${PROTOCOL}" \
		--label "traefik.frontend.rule=Host:${DOMAIN};PathPrefix:/${URI}" \
		ghost:1-alpine

vars: check-env
	# values that will be used to create the blog URL
	@echo '  NAME=${NAME}'
	@echo '  PROTOCOL=${PROTOCOL}'
	@echo '  DOMAIN=${DOMAIN}'
	@echo '  PORT=${PORT}'
	@echo '  URI=${URI}'

check-env:
ifeq ($(wildcard .env),)
	@echo ".env file is missing"
	@exit 1
else
include .env
export
endif


# DOCKER related commands
###

cli-version:
	docker exec -it ${NAME} ghost -v

ps:
	# A lightly formatted version of docker ps
	docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}} ago'

shell:
	docker exec --user node -it ${NAME} bash

logs:
	docker logs -f ${NAME}

stop:
	docker stop ${NAME}

pull:
	docker pull ghost:1-alpine


# RELEASE PROCESS related commands
###

app-version:
	@echo VERSION set to $(VERSION)

release:
	# make sure we are in master
	python update_release.py check --branch=master

	# update versions and ask for confirmation
	python update_release.py
	python update_release.py confirm

	# create branch and tag
	git checkout -b release-$(VERSION)
	git add .
	git commit -m "Prepared release $(VERSION)"
	git push --set-upstream origin release-$(VERSION)

	git tag $(VERSION)
	git tag -f qa-release
	git push --tags --force

	# updating CHANGELOG
	make update-changelog

	# create github release
	python update_release.py publish

	# cancel pre-update of versions
	git checkout versions.py

	# git merge master
	git checkout master
	git merge release-$(VERSION)
	git push

push-qa:
	# update tags
	git tag -f qa-release
	git push --tags --force

	# updating CHANGELOG
	make update-changelog

push-prod:
	@# confirm push to production
	@python update_release.py confirm --prod

	# update tags
	git tag -f prod-release
	git push --tags --force

	# updating CHANGELOG
	make update-changelog

update-changelog:
	# updating CHANGELOG
	github_changelog_generator

	# commit master
	git add CHANGELOG.md
	git commit -m "updated CHANGELOG"
	git push
