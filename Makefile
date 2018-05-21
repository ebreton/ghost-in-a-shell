NAME:=ghost-local
DOMAIN:=localhost
PORT:=3001

dev:
	# Simply start a ghost container making it directly available through $$PORT
	docker run --rm -d --name $(NAME) \
		-v $(shell pwd)/$(NAME):/var/lib/ghost/content \
		-p $(PORT):2368 \
		-e url=http://$(DOMAIN):$(PORT) \
		ghost:1-alpine

traefik:
	# Start a ghost container behind traefik (therefore available through 80 or 443), on path $$NAME
	# Beware of --network used, which is the same one traefik should be using
	docker run --rm -d --name $(NAME) \
		-v $(shell pwd)/$(NAME):/var/lib/ghost/content \
		-e url=http://$(DOMAIN)/$(NAME) \
		--network=proxy \
		--label "traefik.enable=true" \
		--label "traefik.backend=$(NAME)" \
		--label "traefik.frontend.entryPoints=http" \
		--label "traefik.frontend.rule=Host:$(DOMAIN);PathPrefix:/$(NAME)" \
		ghost:1-alpine

ps-light:
	# A lightly formatted version of docker ps
	docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}} ago'

logs:
	docker logs -f $(NAME)

stop:
	docker stop $(NAME)

version:
	docker exec -it $(NAME) ghost -v

shell:
	docker exec --user node -it $(NAME) bash
