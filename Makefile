# ============================================
# SurgiNote Full-Stack Docker Management
# ============================================
# Usage: make [target]
# Run 'make help' to see all available commands

.PHONY: help dev dev-detached prod build build-dev build-prod clean stop logs logs-api logs-client shell-api shell-client restart status health db-backup

# Default target
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# ============================================
# Help
# ============================================
help:
	@echo ""
	@echo "$(CYAN)╔══════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(CYAN)║          SurgiNote Docker Management Commands               ║$(RESET)"
	@echo "$(CYAN)╚══════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(GREEN)Development Commands:$(RESET)"
	@echo "  make dev           Start development environment (foreground)"
	@echo "  make dev-detached  Start development environment (background)"
	@echo ""
	@echo "$(GREEN)Production Commands:$(RESET)"
	@echo "  make prod          Start production environment"
	@echo ""
	@echo "$(GREEN)Build Commands:$(RESET)"
	@echo "  make build         Build all Docker images"
	@echo "  make build-dev     Build development images"
	@echo "  make build-prod    Build production images (no cache)"
	@echo ""
	@echo "$(GREEN)Container Management:$(RESET)"
	@echo "  make stop          Stop all containers"
	@echo "  make clean         Stop containers and remove volumes"
	@echo "  make restart       Restart all services"
	@echo "  make status        Show container status"
	@echo ""
	@echo "$(GREEN)Logging:$(RESET)"
	@echo "  make logs          View all service logs (follow)"
	@echo "  make logs-api      View API server logs"
	@echo "  make logs-client   View client logs"
	@echo ""
	@echo "$(GREEN)Shell Access:$(RESET)"
	@echo "  make shell-api     Open shell in API container"
	@echo "  make shell-client  Open shell in client container"
	@echo ""
	@echo "$(GREEN)Utilities:$(RESET)"
	@echo "  make health        Check health of all services"
	@echo "  make db-backup     Backup SQLite database"
	@echo ""

# ============================================
# Development
# ============================================
dev:
	@echo "$(GREEN)Starting development environment...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

dev-detached:
	@echo "$(GREEN)Starting development environment (detached)...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d
	@echo "$(CYAN)Services started! Access:$(RESET)"
	@echo "  Frontend: http://localhost:3001"
	@echo "  Backend:  http://localhost:8001"
	@echo "  API Docs: http://localhost:8001/docs"

# ============================================
# Production
# ============================================
prod:
	@echo "$(GREEN)Starting production environment...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
	@echo "$(CYAN)Production services started! Access:$(RESET)"
	@echo "  Frontend: http://localhost:8081"
	@echo "  Backend:  http://localhost:8001"

# ============================================
# Build
# ============================================
build:
	@echo "$(YELLOW)Building all Docker images...$(RESET)"
	docker compose build

build-dev:
	@echo "$(YELLOW)Building development images...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml build

build-prod:
	@echo "$(YELLOW)Building production images (no cache)...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache

# ============================================
# Clean & Stop
# ============================================
clean:
	@echo "$(RED)Stopping and removing all containers, networks, and volumes...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.prod.yml down -v --remove-orphans
	docker system prune -f
	@echo "$(GREEN)Cleanup complete!$(RESET)"

stop:
	@echo "$(YELLOW)Stopping all containers...$(RESET)"
	docker compose down

# ============================================
# Logs
# ============================================
logs:
	docker compose logs -f

logs-api:
	docker compose logs -f surginote-api

logs-client:
	docker compose logs -f surginote-client

# ============================================
# Shell Access
# ============================================
shell-api:
	@echo "$(CYAN)Opening shell in API container...$(RESET)"
	docker compose exec surginote-api /bin/bash

shell-client:
	@echo "$(CYAN)Opening shell in client container...$(RESET)"
	docker compose exec surginote-client /bin/sh

# ============================================
# Management
# ============================================
restart:
	@echo "$(YELLOW)Restarting all services...$(RESET)"
	docker compose restart

status:
	@echo "$(CYAN)Container Status:$(RESET)"
	docker compose ps

# ============================================
# Utilities
# ============================================
health:
	@echo "$(CYAN)Checking service health...$(RESET)"
	@echo ""
	@echo -n "API Server (localhost:8001): "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/openapi.json 2>/dev/null && echo "$(GREEN)OK$(RESET)" || echo "$(RED)FAILED$(RESET)"
	@echo -n "Frontend (localhost:3001):   "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 2>/dev/null && echo "$(GREEN)OK$(RESET)" || echo "$(RED)FAILED$(RESET)"

db-backup:
	@echo "$(YELLOW)Creating database backup...$(RESET)"
	@TIMESTAMP=$$(date +%Y%m%d_%H%M%S) && \
	docker compose exec surginote-api cp /app/server_data/surginote.db /app/server_data/surginote_backup_$$TIMESTAMP.db && \
	echo "$(GREEN)Backup created: surginote_backup_$$TIMESTAMP.db$(RESET)"


