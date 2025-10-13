.PHONY: help install dev build test lint clean docker-build docker-run docker-compose-up docker-compose-down k8s-deploy k8s-undeploy helm-install helm-upgrade helm-uninstall

# Variables
DOCKER_IMAGE := jaimehenao8126/backstage-app
DOCKER_TAG := $(shell git rev-parse --short HEAD 2>/dev/null || echo "latest")

help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	yarn install

dev: ## Start development environment
	yarn dev

build: ## Build application
	yarn build

test: ## Run tests
	yarn test

lint: ## Run linting
	yarn lint

clean: ## Clean build artifacts
	yarn clean

docker-build: ## Build Docker image
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest

docker-run: ## Run Docker container
	docker run -p 7007:7007 $(DOCKER_IMAGE):latest

docker-push: ## Push Docker image
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_IMAGE):latest

docker-compose-up: ## Start with docker-compose
	docker-compose up -d

docker-compose-down: ## Stop docker-compose
	docker-compose down -v

k8s-deploy: ## Deploy to Kubernetes
	kubectl apply -f kubernetes/

k8s-undeploy: ## Remove from Kubernetes
	kubectl delete -f kubernetes/

helm-install: ## Install with Helm
	helm install backstage ./helm/backstage

helm-upgrade: ## Upgrade Helm release
	helm upgrade backstage ./helm/backstage

helm-uninstall: ## Uninstall Helm release
	helm uninstall backstage

# Development workflow
setup: install ## Setup development environment
	@echo "Development environment ready!"
	@echo "Run 'make dev' to start development server"

# Production workflow
deploy: build docker-build docker-push ## Build and deploy
	@echo "Application built and pushed to registry"

# Testing workflow
ci: install lint test build ## Run CI pipeline locally
	@echo "CI pipeline completed successfully"

# Database operations
db-migrate: ## Run database migrations
	yarn workspace backend knex migrate:latest

db-seed: ## Seed database
	yarn workspace backend knex seed:run

# Monitoring
health-check: ## Check application health
	curl -f http://localhost:7007/healthcheck || exit 1

# Logs
logs: ## Show application logs
	docker-compose logs -f backstage

# Utility
update-deps: ## Update dependencies
	yarn upgrade --latest

audit: ## Audit dependencies
	yarn audit

format: ## Format code
	yarn prettier --write .