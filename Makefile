.DEFAULT_GOAL := help

# include makefiles/deploy-netlify.mk

## GENERAL ##
OWNER          	= nodejs
SERVICE_NAME    = taller01
APP_DIR         = app
PASSWORD_FILE   = "passwd"

ENV_FILE        ?= .env

## RESULT_VARS ##
PROJECT_NAME    = ${OWNER}-${SERVICE_NAME}
WORKDIR        	= ${APP_DIR}
IMAGE_DEV       = ${OWNER}-dev-${SERVICE_NAME}

## FUNTIONS ##
define detect_user
	-$(eval WHOAMI := $(shell whoami))
	$(eval USERID := $(shell id -u))
	$(shell echo 'USERNAME:x:USERID:USERID::/app:/sbin/nologin' > $(PWD)/passwd.tmpl)
	$(shell \
		cat $(PWD)/passwd.tmpl | sed 's/USERNAME/$(WHOAMI)/g' \
			| sed 's/USERID/$(USERID)/g' > $(PWD)/passwd)
	$(shell rm -rf $(PWD)/passwd.tmpl)
endef

## TARGET DEVELOPMENT ##

ssh: ## Ejecutar ssh: make ssh
	@docker run \
		--workdir "/${WORKDIR}" \
		--rm \
		-it \
		-v "${PWD}/${APP_DIR}":/${APP_DIR} \
		-p 3001:3001 \
		${IMAGE_DEV} sh

build.image: ## Construir imagen para development: make build.image
	# @cp ${PWD}/${APP_DIR}/${REQUIREMENTS_FILE} ${PWD}/docker/dev/${REQUIREMENTS_FILE}
	docker build \
		-f docker/dev/Dockerfile \
		-t $(IMAGE_DEV) \
		docker/dev/ \
		--no-cache
	# @rm -rf ${PWD}/docker/dev/${REQUIREMENTS_FILE}

npm.install: ## Instalar depedencias npm: make npm.install
	$(call detect_user) 
	docker run \
		-it \
		--rm \
		--workdir /${WORKDIR} \
		-u ${USERID}:${USERID} \
		-v ${PWD}/passwd:/etc/passwd:ro \
		-v ${PWD}/${APP_DIR}:/${WORKDIR} \
		--tty=false \
		${IMAGE_DEV} \
		npm install
	rm -rf $(PWD)/$(PASSWORD_FILE)

app.run: ## Ejecutar tu app npm: make app.run
	docker run \
		-it \
		--rm \
		--workdir /${WORKDIR} \
		-v ${PWD}/${APP_DIR}:/${WORKDIR} \
		--tty=false \
		${IMAGE_DEV} \
		node index

## TARGET HELP ##

help:
	@printf "\033[31m%-26s %-39s %s\033[0m\n" "Target" " Help" "Usage"; \
	printf "\033[31m%-26s %-39s %s\033[0m\n"  "------" " ----" "-----"; \
	grep -hE '^\S+:.*## .*$$' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' | sort | awk 'BEGIN {FS = ":"}; {printf "\033[32m%-26s\033[0m %-38s \033[34m%s\033[0m\n", $$1, $$2, $$3}'
