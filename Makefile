COMPOSE ?= docker compose
DRAWIO_BASE_URL ?= http://localhost:8080/
MCP_PORT ?= 3001

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
	DRAWIO_BASE_URL=$(DRAWIO_BASE_URL) MCP_PORT=$(MCP_PORT) npm start

stdio:
	DRAWIO_BASE_URL=$(DRAWIO_BASE_URL) npm run start:stdio

logs:
	$(COMPOSE) logs -f mcp

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --volumes
