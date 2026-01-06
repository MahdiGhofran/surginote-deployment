#!/bin/bash
# ============================================
# SurgiNote Docker Management Script
# ============================================
# Usage: ./start.sh [command]
# Run './start.sh help' for available commands

set -e

# Colors for output
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Print colored output
print_color() {
    echo -e "${1}${2}${RESET}"
}

# Show help menu
show_help() {
    echo ""
    print_color "$CYAN" "╔══════════════════════════════════════════════════════════════╗"
    print_color "$CYAN" "║          SurgiNote Docker Management Commands               ║"
    print_color "$CYAN" "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    print_color "$GREEN" "Development Commands:"
    echo "  ./start.sh dev           Start development environment"
    echo "  ./start.sh dev-detached  Start development (background)"
    echo ""
    print_color "$GREEN" "Production Commands:"
    echo "  ./start.sh prod          Start production environment"
    echo ""
    print_color "$GREEN" "Build Commands:"
    echo "  ./start.sh build         Build all Docker images"
    echo "  ./start.sh build-dev     Build development images"
    echo "  ./start.sh build-prod    Build production images (no cache)"
    echo ""
    print_color "$GREEN" "Container Management:"
    echo "  ./start.sh stop          Stop all containers"
    echo "  ./start.sh clean         Stop containers and remove volumes"
    echo "  ./start.sh restart       Restart all services"
    echo "  ./start.sh status        Show container status"
    echo ""
    print_color "$GREEN" "Logging:"
    echo "  ./start.sh logs          View all service logs"
    echo "  ./start.sh logs-api      View API server logs"
    echo "  ./start.sh logs-client   View client logs"
    echo ""
    print_color "$GREEN" "Shell Access:"
    echo "  ./start.sh shell-api     Open shell in API container"
    echo "  ./start.sh shell-client  Open shell in client container"
    echo ""
    print_color "$GREEN" "Utilities:"
    echo "  ./start.sh health        Check health of all services"
    echo "  ./start.sh db-backup     Backup SQLite database"
    echo ""
    print_color "$YELLOW" "Access Points (after starting):"
    echo "  Frontend (dev):  http://localhost:3001"
    echo "  Frontend (prod): http://localhost:8081"
    echo "  Backend API:     http://localhost:8001"
    echo "  API Docs:        http://localhost:8001/docs"
    echo ""
}

# Check service health
check_health() {
    print_color "$CYAN" "Checking service health..."
    echo ""
    
    # Check API
    echo -n "  API Server (localhost:8001): "
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8001/openapi.json 2>/dev/null | grep -q "200"; then
        print_color "$GREEN" "OK"
    else
        print_color "$RED" "FAILED"
    fi
    
    # Check Frontend
    echo -n "  Frontend (localhost:3001):   "
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 2>/dev/null | grep -q "200"; then
        print_color "$GREEN" "OK"
    else
        print_color "$RED" "FAILED"
    fi
}

# Main command handler
case "${1:-help}" in
    dev)
        print_color "$GREEN" "Starting development environment..."
        echo "Press Ctrl+C to stop"
        echo ""
        docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
        ;;
    dev-detached)
        print_color "$GREEN" "Starting development environment (detached)..."
        docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build -d
        echo ""
        print_color "$CYAN" "Services started! Access:"
        echo "  Frontend: http://localhost:3001"
        echo "  Backend:  http://localhost:8001"
        echo "  API Docs: http://localhost:8001/docs"
        ;;
    prod)
        print_color "$GREEN" "Starting production environment..."
        docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d
        echo ""
        print_color "$CYAN" "Production services started! Access:"
        echo "  Frontend: http://localhost:8081"
        echo "  Backend:  http://localhost:8001"
        echo "  API Docs: http://localhost:8001/docs"
        ;;
    build)
        print_color "$YELLOW" "Building all Docker images..."
        docker compose build
        ;;
    build-dev)
        print_color "$YELLOW" "Building development images..."
        docker compose -f docker-compose.yml -f docker-compose.dev.yml build
        ;;
    build-prod)
        print_color "$YELLOW" "Building production images (no cache)..."
        docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache
        ;;
    clean)
        print_color "$RED" "Stopping and removing all containers, networks, and volumes..."
        docker compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.prod.yml down -v --remove-orphans
        docker system prune -f
        print_color "$GREEN" "Cleanup complete!"
        ;;
    stop)
        print_color "$YELLOW" "Stopping all containers..."
        docker compose down
        ;;
    logs)
        docker compose logs -f
        ;;
    logs-api)
        docker compose logs -f surginote-api
        ;;
    logs-client)
        docker compose logs -f surginote-client
        ;;
    shell-api)
        print_color "$CYAN" "Opening shell in API container..."
        docker compose exec surginote-api /bin/bash
        ;;
    shell-client)
        print_color "$CYAN" "Opening shell in client container..."
        docker compose exec surginote-client /bin/sh
        ;;
    restart)
        print_color "$YELLOW" "Restarting all services..."
        docker compose restart
        ;;
    status)
        print_color "$CYAN" "Container Status:"
        docker compose ps
        ;;
    health)
        check_health
        ;;
    db-backup)
        print_color "$YELLOW" "Creating database backup..."
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        docker compose exec surginote-api cp /app/server_data/surginote.db /app/server_data/surginote_backup_${TIMESTAMP}.db
        print_color "$GREEN" "Backup created: surginote_backup_${TIMESTAMP}.db"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_color "$RED" "Unknown command: $1"
        echo "Run './start.sh help' for available commands"
        exit 1
        ;;
esac

