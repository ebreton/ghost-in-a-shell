NAME:=ghost-local
PORT:=3001

dev:
	docker run --rm -d --name $(NAME) \
		-p $(PORT):2368 \
		-e url=http://localhost:$(PORT) \
		-v $(shell pwd)/$(NAME):/var/lib/ghost/content \
		ghost:1-alpine

version:
	docker exec -it $(NAME) ghost -v

shell:
	docker exec --user node -it $(NAME) bash
