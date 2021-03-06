#!make
# Default values, can be overridden either on the command line of make
# or in .env

.PHONY: dev qa prod vars save-vars check-env check-release-env check-prod-env gatling \
	cli-version ps shell logs stop pull restart restart-prod upgrade upgrade-prod \
	app-version release push-qa push-prod update-changelog 

VERSION:=$(shell python update_release.py -v)
p?=./

dev: check-env
	# Simply start a ghost container making it directly available through $$PORT
	docker run --rm -d --name ${NAME} \
		-v $(shell pwd)/instances/${NAME}:/var/lib/ghost/content \
		-p ${PORT}:2368 \
		-e url=http://${DOMAIN}:${PORT} \
		ghost:${GHOST_VERSION}-alpine
	make save-vars

qa: check-env
	# Start a ghost container behind traefik (therefore available through 80 or 443), on path $$NAME
	# Beware of --network used, which is the same one traefik should be using
	docker run --restart=always -d --name ${NAME} \
		-v $(shell pwd)/instances/${NAME}:/var/lib/ghost/content \
		-e url=${PROTOCOL}://${DOMAIN}/${URI} \
		--network=traefik-public \
		--label 'traefik.enable=true' \
		--label 'traefik.docker.network=traefik-public' \
		--label 'traefik.http.middlewares.stripprefix-${NAME}.stripprefix.prefixes=/${NAME}' \
		--label 'traefik.http.routers.plain-${NAME}.entrypoints=web' \
		--label 'traefik.http.routers.plain-${NAME}.rule=Host(`${DOMAIN}`)' \
		--label 'traefik.http.routers.plain-${NAME}.middlewares=redirect-to-https' \
		--label 'traefik.http.routers.${NAME}.entrypoints=websecure' \
		--label 'traefik.http.routers.${NAME}.rule=Host(`${DOMAIN}`)' \
		--label 'traefik.http.routers.${NAME}.tls.certresolver=dnsresolver' \
		--label 'traefik.http.routers.${NAME}.middlewares=stripprefix-${NAME}' \
		ghost:${GHOST_VERSION}-alpine
	make save-vars

# for backward compatibility
traefik: qa
	@echo ""
	@echo "!! DEPRECATION WARNING: 'make traefik' is replaced by 'make qa'. This command will be dropped in version 0.4"

prod: check-env check-prod-env
	# Same configuration as make `traefik`, specifying DB
	docker run --restart=always -d --name ${NAME} \
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
		--network=traefik-public \
		--label "traefik.enable=true" \
		--label "traefik.docker.network=traefik-public" \
		--label "traefik.http.routers.plain-${NAME}.entrypoints=web" \
		--label "traefik.http.routers.plain-${NAME}.rule=Host(`${DOMAIN}`) && Path(`/${URI}`)" \
		--label "traefik.http.routers.plain-${NAME}.middlewares=redirect-to-https" \
		--label "traefik.http.routers.${NAME}.entrypoints=websecure" \
		--label "traefik.http.routers.${NAME}.rule=Host(`${DOMAIN}`) && Path(`/${URI}`)" \
		--label "traefik.http.routers.${NAME}.tls.certresolver=dnsresolver" \
		ghost:${GHOST_VERSION}-alpine
	make save-vars				

vars: check-env
	# common
	@echo '  p=${p}.env'
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

save-vars:
ifeq ($(wildcard instances/${NAME}/.env),)
	@echo "creating instances/${NAME}/.env"
	@echo '# This file has been generated when you created the instance.' > ./instances/${NAME}/.env
	@echo '# Feel free to adapt it manually' >> ./instances/${NAME}/.env
	@echo 'NAME=${NAME}' >> ./instances/${NAME}/.env
	@echo 'GHOST_VERSION=${GHOST_VERSION}' >> ./instances/${NAME}/.env
	@echo 'PORT=${PORT}' >> ./instances/${NAME}/.env
	@echo 'PROTOCOL=${PROTOCOL}' >> ./instances/${NAME}/.env
	@echo 'DOMAIN=${DOMAIN}' >> ./instances/${NAME}/.env
	@echo 'URI=${URI}' >> ./instances/${NAME}/.env
else
	@echo "instances/${NAME}/.env already exists"
endif

check-prod-env:
ifeq ($(wildcard etc/prod.env),)
	@echo "etc/prod.env file is missing"
	@exit 1
else
include etc/prod.env
export
endif

check-release-env:
ifeq ($(wildcard etc/release.env),)
	@echo "etc/release.env file is missing. Create it from etc/release.env.sample"
	@exit 1
else
include etc/release.env
export
endif

check-env:
ifeq ($(wildcard ${p}.env),)
	@echo "${p}.env file is missing"
	@exit 1
else
include ${p}.env
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
		--network=traefik-public \
		denvazh/gatling -m -s ghost.GhostFrontend

# DOCKER related commands
###

build:
	cd bin && docker build -t python-requests .

cli-version:
	docker exec -it ${NAME} ghost -v
	@echo Latest version on Docker Hub: $(shell \
		docker run --rm -it \
			-v $(PWD)/bin/find_latest_versions.py:/usr/src/app/find_latest_versions.py \
			python-requests find_latest_versions.py)

ps:
	# A lightly formatted version of docker ps
	docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}} ago'

shell:
	docker exec --user node -it ${NAME} bash

logs:
	docker logs -f ${NAME}

rm:
	docker rm ${NAME}

stop:
	docker stop ${NAME}

pull: build
	docker pull ghost:${GHOST_VERSION}-alpine

restart: stop rm dev logs
restart-qa: stop rm qa logs
restart-prod: stop rm prod logs

upgrade: pull stop rm dev cli-version
upgrade-qa: pull stop rm qa cli-version
upgrade-prod: pull stop rm prod cli-version


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

changelog: check-release-env
	@echo updating CHANGELOG...
	@docker run -it --rm \
		-v $(PWD):/usr/local/src/your-app \
		ferrarimarco/github-changelog-generator \
		-u ${GITHUB_OWNER} -p ${GITHUB_REPO} -t ${CHANGELOG_GITHUB_TOKEN}

	# commit master
	git add CHANGELOG.md
	git commit -m "updated CHANGELOG"
	git push


release: check-release-env
	# make sure requests is available
	python -c "import requests"

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
