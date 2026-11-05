# cliproxy Makefile
# Run from the repo root or from ~/cliproxyapi on the hub.

.PHONY: up down logs health backup setup signin-codex signin-claude clean

COMPOSE ?= docker compose
ENV_FILE ?= .env

up: ## Start cliproxyapi (and cloudflared with 'make up-tunnel')
	$(COMPOSE) up -d

up-tunnel: ## Start cliproxyapi + cloudflared tunnel
	$(COMPOSE) --profile tunnel up -d

down: ## Stop all services
	$(COMPOSE) down

logs: ## Follow cliproxyapi logs
	$(COMPOSE) logs -f cliproxyapi

health: ## Run health check
	@if [ -f $(ENV_FILE) ]; then export $$(grep -v '^#' $(ENV_FILE) | xargs); fi; \
	bash scripts/health-check.sh

backup: ## Back up data/ directory
	bash scripts/backup.sh

setup: ## Run hub setup script (on Ubuntu server)
	bash scripts/setup-hub.sh

signin-codex: ## Run Codex device login via Docker
	bash scripts/signin-codex.sh

signin-claude: ## Run Claude login via Docker (interactive)
	docker run --rm -it -v "$$(pwd)/data:/app/data" eceasy/cli-proxy-api:latest -claude-login

clean: ## Stop and remove containers (keeps data/)
	$(COMPOSE) down --remove-orphans

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
