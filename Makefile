WORKER_REPLICAS=4

init:
	docker swarm init || true
	mkdir -p ./.keys
	mkdir -p ./ips
	ssh-keygen -t rsa -b 4096 -f ./.keys/manager_rsa -N ""
.PHONY: init

build:
	docker rmi -f grid_search_julia_manager || true
	docker rmi -f grid_search_julia_worker || true
	docker build -t grid_search_julia_manager -f ./Dockerfile-manager .
	docker build -t grid_search_julia_worker -f ./Dockerfile-worker .
.PHONY: build

deploy: remove
	mkdir -p graphite
	mkdir -p grafana_config
	until \
	WORKER_REPLICAS=$(WORKER_REPLICAS) \
	docker stack deploy -c docker-compose.yaml gs_julia; \
	do sleep 1; done
.PHONY: deploy

remove:
	sudo rm -f ./ips/*
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