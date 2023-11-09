init:
	mkdir -p ./.keys
	ssh-keygen -t rsa -b 4096 -f ./.keys/manager_rsa -N ""
.PHONY: init

build:
	docker rmi -f julia_manager || true
	docker rmi -f julia_worker || true
	docker build -t julia_manager -f ./Dockerfile-manager .
	docker build -t julia_worker -f ./Dockerfile-worker .
.PHONY: build


deploy: remove
	docker stack deploy -c docker-compose.yaml gs_julia
.PHONY: deploy

remove:
	rm -f ./ips/*
	if docker stack ls | grep -q gs_julia; then \
            docker stack rm gs_julia; \
	fi
.PHONY: remove

manager_bash:
	docker exec -it $(shell docker ps -q -f name=gs_julia_manager) bash
.PHONY: manager_bash

worker_bash:
	docker exec -it $(shell docker ps -q -f name=gs_julia_worker) bash
.PHONY: worker_bash