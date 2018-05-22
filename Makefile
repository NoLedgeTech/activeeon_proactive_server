.PHONY: help build start logs test stop deploy bash sh

DOCKER_NAME=activeeon_proactive_server
DOCKER_VER=0.0.1
DCR_HOST=localhost
DCR_PORT=5000
ENV_FILE=$(PWD)/.env

# Get Container ID if it's running
CONTAINER_ID := $(shell bash -c 'docker ps -a -q -f name=${DOCKER_NAME}_${DOCKER_VER}')

# Get current directory
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(dir $(MKFILE_PATH))

ifneq ("$(wildcard $(ENV_FILE))", "")
	include $(ENV_FILE)
	export $(shell sed 's/=.*//' $(ENV_FILE))
endif

help: ##   shows all available targets
	@echo ""
	@echo "ActiveEON Proactive server"
	@echo ""
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/\(.*\)\:.*##/\1:/'
	@echo ""

build: ##  builds container image
	@docker build -t ${DOCKER_NAME}:${DOCKER_VER} .

start: ##  start container
	@echo Starting container ${DOCKER_NAME}_${DOCKER_VER}
	@docker run -d -i \
		-p 8080:8080 \
		--name ${DOCKER_NAME}_${DOCKER_VER} \
		--volume ${CURRENT_DIR}/config:/opt/activeeon_proactive_server/config \
		--volume ${CURRENT_DIR}/defaultuser:/opt/activeeon_proactive_server/data/defaultuser \
		-t ${DOCKER_NAME}:${DOCKER_VER} \
		/scripts/activeeon_proactive_server_entrypoint.sh

logs: ##   show container logs (Ctrl-C to stop)
	@docker logs ${CONTAINER_ID} -f

test: ##   run all tests
	@echo "Checking scheduling-api"
	@tests/test_url.sh http://localhost:8080/scheduling-api
	@echo "Checking studio"
	@tests/test_url.sh http://localhost:8080/studio
	@echo "Checking catalog"
	@tests/test_url.sh http://localhost:8080/catalog
	@echo "Checking rm"
	@tests/test_url.sh http://localhost:8080/rm
	@echo "Checking automation-dashboard"
	@tests/test_url.sh http://localhost:8080/automation-dashboard
	@echo "Checking rest"
	@tests/test_url.sh http://localhost:8080/rest
	@echo "Checking scheduler"
	@tests/test_url.sh http://localhost:8080/scheduler
	@echo "Not Checking connector-iaas"
#	@tests/test_url.sh http://localhost:8080/connector-iaas
	@echo "Not Checking proactive-cloud-watch"
#	@tests/test_url.sh http://localhost:8080/proactive-cloud-watch
	@echo "Not Checking job-planner"
#	@tests/test_url.sh http://localhost:8080/job-planner
	@echo "Not Checking cloud-automation-service"
#	@tests/test_url.sh http://localhost:8080/cloud-automation-service
	@echo "Not Checking notification-service"
#	@tests/test_url.sh http://localhost:8080/notification-service

stop: ##   stops and removes container
	@echo Stopping container ${CONTAINER_ID}
	@docker stop -t 0 ${CONTAINER_ID}
	@echo Removing container ${DOCKER_NAME}_${DOCKER_VER}
	@docker rm ${CONTAINER_ID}

deploy: ## deploys image to container registry
	@echo Tagging container ${DOCKER_NAME}:${DOCKER_VER}
	@docker tag ${DOCKER_NAME}:${DOCKER_VER} ${DCR_HOST}:${DCR_PORT}/${DOCKER_NAME}
	@echo Deploying container ${DOCKER_NAME}:${DOCKER_VER}
	@docker push ${DCR_HOST}:${DCR_PORT}/${DOCKER_NAME}

bash: ##   login to container using bash
	@echo "Login into container ${DOCKER_NAME}:${DOCKER_VER} -> ${CONTAINER_ID}"
	@docker exec -u 0 -it ${CONTAINER_ID} bash

sh: ##     login to container using sh
	@echo "Login into container ${DOCKER_NAME}:${DOCKER_VER} -> ${CONTAINER_ID}"
	@docker exec -u 0 -it ${CONTAINER_ID} sh
