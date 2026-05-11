COMPOSE ?= docker compose

-include .env

DRAWIO_BASE_URL ?= http://localhost:8080/
DRAWIO_OUTPUT_DIR ?= ./diagrams
VIEWER_PATH ?=
MCP_PORT ?= 3001
MCP_LISTEN ?= 127.0.0.1

MCP_ENV = DRAWIO_BASE_URL=$(DRAWIO_BASE_URL) DRAWIO_OUTPUT_DIR=$(DRAWIO_OUTPUT_DIR) MCP_PORT=$(MCP_PORT) MCP_LISTEN=$(MCP_LISTEN)
ifneq ($(strip $(VIEWER_PATH)),)
MCP_ENV += VIEWER_PATH=$(VIEWER_PATH)
endif
ifneq ($(strip $(ALLOWED_HOSTS)),)
MCP_ENV += ALLOWED_HOSTS=$(ALLOWED_HOSTS)
endif
ifneq ($(strip $(DOMAIN)),)
MCP_ENV += DOMAIN=$(DOMAIN)
endif
ifneq ($(strip $(OPEN_BROWSER)),)
MCP_ENV += OPEN_BROWSER=$(OPEN_BROWSER)
endif

.PHONY: help install check start up up-detached drawio mcp stdio logs down clean

help:
	@printf "drawio-mcp targets:\n"
	@printf "  make start        Build and start the full local stack\n"
	@printf "  make up           Alias for make start\n"
	@printf "  make up-detached  Start the full local stack in the background\n"
	@printf "  make drawio       Start only draw.io and image export\n"
	@printf "  make mcp          Start the MCP server with Node.js\n"
	@printf "  make stdio        Start the MCP server over stdio\n"
	@printf "  make logs         Follow Docker logs for the MCP service\n"
	@printf "  make down         Stop the Docker stack\n"
	@printf "  make check        Run syntax checks\n"

install:
	npm install

check:
	npm run check

start up:
	$(COMPOSE) up --build

up-detached:
	$(COMPOSE) up --build -d

drawio:
	$(COMPOSE) up drawio

mcp:
	$(MCP_ENV) npm start

stdio:
	$(MCP_ENV) npm run start:stdio

logs:
	$(COMPOSE) logs -f mcp

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --volumes
