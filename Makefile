#!make
# Default values, can be overridden either on the command line of make
# or in .env

.PHONY: dev qa prod vars \
	cli-version ps shell logs stop pull restart restart-prod upgrade upgrade-prod \
	app-version release push-qa push-prod update-changelog 

VERSION:=$(shell python update_release.py -v)

dev: check-env
	# Simply start a ghost container making it directly available through $$PORT
	docker run --rm -d --name ${NAME} \
		-v $(shell pwd)/instances/${NAME}:/var/lib/ghost/content \
		-p ${PORT}:2368 \
		-e url=http://${DOMAIN}:${PORT} \
		ghost:${GHOST_VERSION}-alpine

qa: check-env
	# Start a ghost container behind traefik (therefore available through 80 or 443), on path $$NAME
	# Beware of --network used, which is the same one traefik should be using
	docker run --rm -d --name ${NAME} \
		-v $(shell pwd)/instances/${NAME}:/var/lib/ghost/content \
		-e url=${PROTOCOL}://${DOMAIN}/${URI} \
		--network=proxy \
		--label "traefik.enable=true" \
		--label "traefik.backend=${NAME}" \
		--label "traefik.frontend.entryPoints=${PROTOCOL}" \
		--label "traefik.frontend.rule=Host:${DOMAIN};PathPrefix:/${URI}" \
		ghost:${GHOST_VERSION}-alpine

# for backward compatibility
traefik: qa
	@echo ""
	@echo "!! DEPRECATION WARNING: 'make traefik' is replaced by 'make qa'. This command will be dropped in version 0.4"

prod: check-prod-env
	# Same configuration as make `traefik`, specifying DB
	docker run --rm -d --name ${NAME} \
		-v $(shell pwd)/instances/${NAME}:/var/lib/ghost/content \
		-e database__client=mysql \
		-e database__connection__host=db-shared \
		-e database__connection__user=root \
		-e database__connection__password=${MYSQL_ROOT_PASSWORD} \
		-e database__connection__database=${NAME} \
		-e mail__transport=SMTP \
		-e mail__options__service=Mailgun \
		-e mail__options__auth__user=${MAILGUN_LOGIN} \
		-e mail__options__auth__pass=${MAILGUN_PASSWORD} \
		-e url=${PROTOCOL}://${DOMAIN}/${URI} \
		--network=proxy \
		--label "traefik.enable=true" \
		--label "traefik.backend=${NAME}" \
		--label "traefik.frontend.entryPoints=${PROTOCOL}" \
		--label "traefik.frontend.rule=Host:${DOMAIN};PathPrefix:/${URI}" \
		ghost:${GHOST_VERSION}-alpine  

vars: check-env
	# common
	@echo '  NAME=${NAME}'
	@echo '  GHOST_VERSION=${GHOST_VERSION}'
	# values used for dev
	@echo '  PORT=${PORT}'
	# values used by traefik (qa & prod)
	@echo '  PROTOCOL=${PROTOCOL}'
	@echo '  DOMAIN=${DOMAIN}'
	@echo '  URI=${URI}'
	# values used for prod
	@echo '  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}'
	@echo '  MAILGUN_LOGIN=${MAILGUN_LOGIN}'
	@echo '  MAILGUN_PASSWORD=${MAILGUN_PASSWORD}'
	# values used for load tests
	@echo '  GATLING_BASE_URL=${GATLING_BASE_URL}'
	@echo '  GATLING_USERS=${GATLING_USERS}'
	@echo '  GATLING_RAMP=${GATLING_RAMP}'

check-prod-env:
ifeq ($(wildcard etc/prod.env),)
	@echo "etc/prod.env file is missing"
	@exit 1
else
include etc/prod.env
export
endif

check-env:
ifeq ($(wildcard .env),)
	@echo ".env file is missing"
	@exit 1
else
include .env
export
endif

GATLING_BASE_URL?=${PROTOCOL}://${NAME}:2368/${URI}
GATLING_USERS?=3
GATLING_RAMP?=5

gatling:
	docker run -it --rm \
		-v $(shell pwd)/etc/gatling-conf.scala:/opt/gatling/user-files/simulations/ghost/GhostFrontend.scala \
		-v $(shell pwd)/gatling-results:/opt/gatling/results \
		-e JAVA_OPTS="-Dusers=${GATLING_USERS} -Dramp=${GATLING_RAMP} -DbaseUrl=${GATLING_BASE_URL}" \
		--network=proxy \
		denvazh/gatling -m -s ghost.GhostFrontend

# DOCKER related commands
###

cli-version:
	docker exec -it ${NAME} ghost -v
	@echo Latest version on Docker Hub: $(shell python find_latest_versions.py)

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
	docker pull ghost:${GHOST_VERSION}-alpine

restart: stop dev logs
restart-qa: stop qa logs
restart-prod: stop prod logs

upgrade: pull restart
upgrade-qa: pull restart-qa
upgrade-prod: pull restart-prod


# RELEASE PROCESS related commands
###

app-version:
	@echo VERSION set to $(VERSION)

release-vars:
	@echo '  GITHUB_OWNER=${GITHUB_OWNER}'
	@echo '  GITHUB_REPO=${GITHUB_REPO}'
	@echo '  GITHUB_USER=${GITHUB_USER}'
	@echo '  GITHUB_TOKEN=${GITHUB_TOKEN}'
	@echo '  CHANGELOG_GITHUB_TOKEN=${CHANGELOG_GITHUB_TOKEN}'

release-pull:
	docker pull ferrarimarco/github-changelog-generator

changelog:
	@echo updating CHANGELOG...
	@docker run -it --rm \
		-v $(PWD):/usr/local/src/your-app \
		ferrarimarco/github-changelog-generator \
		-u ${GITHUB_OWNER} -p ${GITHUB_REPO} -t ${CHANGELOG_GITHUB_TOKEN}

	# commit master
	git add CHANGELOG.md
	git commit -m "updated CHANGELOG"
	git push


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
	make changelog

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
	make changelog

push-prod:
	@# confirm push to production
	@python update_release.py confirm --prod

	# update tags
	git tag -f prod-release
	git push --tags --force

	# updating CHANGELOG
	make changelog