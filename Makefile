# DevOps Bookstore Makefile
# This demonstrates Infrastructure as Code and automation for college project

.PHONY: help install init plan apply destroy dev prod clean status logs health check-deps

# Default environment
ENV ?= dev

# Help target
help: ## Show this help message
	@echo "DevOps Bookstore - Infrastructure Management"
	@echo "========================================="
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Environment Variables:"
	@echo "  ENV=dev|staging|prod    Set deployment environment (default: dev)"
	@echo ""
	@echo "Examples:"
	@echo "  make dev                Deploy to development environment"
	@echo "  make prod               Deploy to production environment" 
	@echo "  make ENV=staging apply  Deploy to staging environment"
	@echo "  make destroy ENV=prod   Destroy production environment"

# Dependency checks
check-deps: ## Check if required tools are installed
	@echo "Checking dependencies..."
	@which docker >/dev/null 2>&1 || (echo "❌ Docker not found. Please install Docker." && exit 1)
	@which terraform >/dev/null 2>&1 || (echo "❌ Terraform not found. Please install Terraform." && exit 1)
	@echo "✅ All dependencies are installed"

# Install and setup
install: check-deps ## Install dependencies and setup project
	@echo "Setting up DevOps Bookstore project..."
	@cd infra && terraform init
	@echo "✅ Project setup complete"

# Terraform operations
init: ## Initialize Terraform
	@cd infra && terraform init

plan: ## Plan Terraform deployment
	@echo "Planning deployment for $(ENV) environment..."
	@./deploy.sh -e $(ENV) -a plan

apply: ## Apply Terraform deployment
	@echo "Deploying to $(ENV) environment..."
	@./deploy.sh -e $(ENV) -a apply

apply-auto: ## Apply Terraform deployment with auto-approve
	@echo "Auto-deploying to $(ENV) environment..."
	@./deploy.sh -e $(ENV) -a apply -y

destroy: ## Destroy Terraform deployment
	@echo "Destroying $(ENV) environment..."
	@./deploy.sh -e $(ENV) -a destroy

destroy-auto: ## Destroy Terraform deployment with auto-approve
	@echo "Auto-destroying $(ENV) environment..."
	@./deploy.sh -e $(ENV) -a destroy -y

# Environment shortcuts
dev: ## Deploy to development environment
	@make apply ENV=dev

staging: ## Deploy to staging environment
	@make apply ENV=staging

prod: ## Deploy to production environment
	@make apply ENV=prod

# Docker operations
build: ## Build Docker images manually
	@echo "Building Docker images..."
	@docker build -t bookstore-backend:latest ./backend
	@docker build -t bookstore-frontend:latest .
	@echo "✅ Docker images built"

# Monitoring and status
status: ## Show deployment status
	@echo "DevOps Bookstore Deployment Status"
	@echo "================================="
	@echo ""
	@echo "Docker Containers:"
	@docker ps --filter "label=project=devops-bookstore" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" || echo "No containers running"
	@echo ""
	@echo "Docker Images:"
	@docker images --filter "reference=bookstore-*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" || echo "No images found"
	@echo ""
	@echo "Docker Networks:"
	@docker network ls --filter "name=bookstore" --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}" || echo "No networks found"

logs: ## Show container logs
	@echo "Showing logs for $(ENV) environment..."
	@docker logs $(ENV)-backend --tail 50 -f 2>/dev/null || echo "Backend container not running"
	@docker logs $(ENV)-frontend --tail 50 -f 2>/dev/null || echo "Frontend container not running"

health: ## Check application health
	@echo "Checking application health..."
	@echo "Backend Health:"
	@curl -s http://localhost:5001/health | jq . 2>/dev/null || echo "❌ Backend not responding"
	@echo ""
	@echo "Frontend Health:"
	@curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:3000 || echo "❌ Frontend not responding"

# Cleanup operations
clean: ## Clean up Docker resources
	@echo "Cleaning up Docker resources..."
	@docker container prune -f
	@docker image prune -f
	@docker network prune -f
	@echo "✅ Cleanup complete"

clean-all: ## Clean up all Docker resources including volumes
	@echo "Cleaning up all Docker resources..."
	@docker system prune -af
	@echo "✅ Full cleanup complete"

# Testing
test-api: ## Test backend API endpoints
	@echo "Testing backend API..."
	@curl -s http://localhost:5001/health && echo ""
	@curl -s http://localhost:5001/api/books | jq '. | length' && echo " books found"

# Format and validate
fmt: ## Format Terraform files
	@cd infra && terraform fmt

validate: ## Validate Terraform configuration
	@cd infra && terraform validate

# Show Terraform outputs
outputs: ## Show Terraform outputs
	@cd infra && terraform output
