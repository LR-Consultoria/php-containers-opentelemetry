# Makefile for PHP Docker Images

# Configuration
REGISTRY ?= ghcr.io/lrconsultoria
TAG_SUFFIX ?= alpine
PHP_VERSIONS := 8.2 8.3 8.4
VARIANTS := base swoole nginx frankenphp

# Colors
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

.PHONY: help build build-all push push-all test test-all clean

help: ## Show this help message
	@echo "$(BLUE)PHP Docker Images Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build specific image (usage: make build VERSION=8.3 VARIANT=base)
	@if [ -z "$(VERSION)" ] || [ -z "$(VARIANT)" ]; then \
		echo "$(RED)Error: VERSION and VARIANT are required$(NC)"; \
		echo "Usage: make build VERSION=8.3 VARIANT=base"; \
		exit 1; \
	fi
	@echo "$(BLUE)Building $(VARIANT) image for PHP $(VERSION)...$(NC)"
	@./scripts/build.sh $(VERSION) $(VARIANT) $(TAG_SUFFIX)

build-all: ## Build all images
	@echo "$(BLUE)Building all PHP Docker images...$(NC)"
	@./scripts/build-all.sh $(TAG_SUFFIX)

push: ## Push specific image (usage: make push VERSION=8.3 VARIANT=base)
	@if [ -z "$(VERSION)" ] || [ -z "$(VARIANT)" ]; then \
		echo "$(RED)Error: VERSION and VARIANT are required$(NC)"; \
		echo "Usage: make push VERSION=8.3 VARIANT=base"; \
		exit 1; \
	fi
	@echo "$(BLUE)Pushing $(VARIANT) image for PHP $(VERSION)...$(NC)"
	@PUSH=1 ./scripts/build.sh $(VERSION) $(VARIANT) $(TAG_SUFFIX)

push-all: ## Push all built images
	@echo "$(BLUE)Pushing all PHP Docker images...$(NC)"
	@./scripts/push-all.sh $(TAG_SUFFIX)

test: ## Test specific image (usage: make test VERSION=8.3 VARIANT=base)
	@if [ -z "$(VERSION)" ] || [ -z "$(VARIANT)" ]; then \
		echo "$(RED)Error: VERSION and VARIANT are required$(NC)"; \
		echo "Usage: make test VERSION=8.3 VARIANT=base"; \
		exit 1; \
	fi
	@echo "$(BLUE)Testing $(VARIANT) image for PHP $(VERSION)...$(NC)"
	@./scripts/test.sh $(VERSION) $(VARIANT) $(TAG_SUFFIX)

test-all: ## Test all built images
	@echo "$(BLUE)Testing all PHP Docker images...$(NC)"
	@for version in $(PHP_VERSIONS); do \
		for variant in $(VARIANTS); do \
			echo "$(YELLOW)Testing $$variant:$$version-$(TAG_SUFFIX)...$(NC)"; \
			./scripts/test.sh $$version $$variant $(TAG_SUFFIX) || exit 1; \
		done \
	done
	@echo "$(GREEN)All tests passed!$(NC)"

clean: ## Clean up Docker images and containers
	@echo "$(YELLOW)Cleaning up Docker resources...$(NC)"
	@docker system prune -f
	@docker image prune -f
	@echo "$(GREEN)Cleanup completed!$(NC)"

clean-images: ## Remove all built images
	@echo "$(YELLOW)Removing all built PHP images...$(NC)"
	@for version in $(PHP_VERSIONS); do \
		for variant in $(VARIANTS); do \
			image_name="php-$$variant"; \
			if [ "$$variant" = "base" ]; then image_name="php-base"; fi; \
			docker rmi $(REGISTRY)/$$image_name:$$version-$(TAG_SUFFIX) 2>/dev/null || true; \
		done \
	done
	@echo "$(GREEN)Images removed!$(NC)"

list-images: ## List all built images
	@echo "$(BLUE)Built PHP Docker images:$(NC)"
	@docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" | grep "$(REGISTRY)/php-"

build-matrix: ## Build images using buildx for multi-platform
	@echo "$(BLUE)Building multi-platform images...$(NC)"
	@BUILDX=1 ./scripts/build-all.sh $(TAG_SUFFIX)

# Development targets
dev-setup: ## Setup development environment
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@cp examples/env.example .env
	@mkdir -p logs/nginx logs/supervisor
	@echo "$(GREEN)Development environment ready!$(NC)"

dev-up: ## Start development environment
	@echo "$(BLUE)Starting development environment...$(NC)"
	@docker-compose -f examples/laravel-base.yml up -d
	@echo "$(GREEN)Development environment started!$(NC)"

dev-down: ## Stop development environment
	@echo "$(YELLOW)Stopping development environment...$(NC)"
	@docker-compose -f examples/laravel-base.yml down
	@echo "$(GREEN)Development environment stopped!$(NC)"

# CI/CD targets
ci-build: ## Build images for CI/CD
	@echo "$(BLUE)Building images for CI/CD...$(NC)"
	@NO_CACHE=1 BUILDX=1 ./scripts/build-all.sh $(TAG_SUFFIX)

ci-test: ## Run tests for CI/CD
	@echo "$(BLUE)Running tests for CI/CD...$(NC)"
	@$(MAKE) test-all

ci-push: ## Push images for CI/CD
	@echo "$(BLUE)Pushing images for CI/CD...$(NC)"
	@$(MAKE) push-all
