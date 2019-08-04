.phony: build run reload

include .env

NAMESPACE := iam
NAME := keycloak
VERSION := 6.0.1

TAG := $(NAMESPACE)/$(NAME):$(VERSION)

client/node_modules:
	@cd client; npm install

build:
	@docker build -t $(TAG) .

realm.js.o:
	@sed -e "s|USER_INFO_URL|$(USER_INFO_URL)|" \
		-e "s|CLIENT_ID|$(CLIENT_ID)|" \
		-e "s|CLIENT_SECRET|$(CLIENT_SECRET)|" \
		-e "s|TOKEN_URL|$(TOKEN_URL)|" \
		-e "s|JWKS_URL|$(JWKS_URL)|" \
		-e "s|ISSUER|$(ISSUER)|" \
		-e "s|AUTHORIZATION_URL|$(AUTHORIZATION_URL)|" \
		< realm.json > realm.js.o

run: build realm.js.o client/node_modules
	@cd client; npm start&
	@docker run --name $(NAME) --rm -it -p 8080:8080 -p 8443:8443 \
	 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin \
	 -e KEYCLOAK_IMPORT=/tmp/realm.js.o \
	 -e jboss.user_info_url=$(USER_INFO_URL) \
	 -v $(shell pwd):/tmp \
	 $(TAG)

reload:
	@docker exec keycloak /opt/jboss/keycloak/bin/jboss-cli.sh --connect reload
