# 🐳 SurgiNote Docker Setup

> Production-ready Docker orchestration for the SurgiNote full-stack application.

## 📋 Overview

This Docker setup provides containerized development and production environments for:

- **Frontend (surginote-client)**: React 19 + Vite application
- **Backend (surginote-server)**: FastAPI + SQLite application

## 🚀 Quick Start

### Prerequisites

- [Docker](https://www.docker.com/get-started) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)

### Development Mode

```bash
# Using the start script
./start.sh dev

# OR using Make
make dev
```

### Production Mode

```bash
# Using the start script
./start.sh prod

# OR using Make
make prod
```

## 🌐 Access Points

| Service            | Development                | Production                 |
| ------------------ | -------------------------- | -------------------------- |
| Frontend           | http://localhost:3001      | http://localhost:8081      |
| Backend API        | http://localhost:8001      | http://localhost:8001      |
| API Docs (Swagger) | http://localhost:8001/docs | http://localhost:8001/docs |

## 📁 Project Structure

```
SurgiNote-FrontEnd/
├── docker-compose.yml          # Base orchestration
├── docker-compose.dev.yml      # Development overrides
├── docker-compose.prod.yml     # Production overrides
├── env.example                 # Environment template
├── Makefile                    # Make commands
├── start.sh                    # Bash script (WSL/Linux/Mac)
├── DOCKER-README.md            # This file
│
├── surginote-client/           # React frontend
│   ├── Dockerfile              # Production build
│   ├── Dockerfile.dev          # Development build
│   └── nginx.conf              # Production web server
│
└── surginote-server/           # FastAPI backend
    ├── Dockerfile              # Production build
    ├── Dockerfile.dev          # Development build
    ├── server_data/            # SQLite database
    ├── videos/                 # Video uploads
    ├── profile_images/         # User avatars
    └── voice_recordings/       # Audio files
```

## 🔧 Commands Reference

### Bash Script (WSL/Linux/Mac)

```bash
./start.sh dev           # Start development environment
./start.sh dev-detached  # Start development (background)
./start.sh prod          # Start production environment
./start.sh build         # Build all images
./start.sh build-dev     # Build development images
./start.sh build-prod    # Build production images
./start.sh clean         # Remove containers and volumes
./start.sh logs          # View all logs
./start.sh logs-api      # View API logs
./start.sh logs-client   # View client logs
./start.sh stop          # Stop all containers
./start.sh restart       # Restart services
./start.sh status        # Show container status
./start.sh health        # Check service health
./start.sh shell-api     # Open API container shell
./start.sh shell-client  # Open client container shell
./start.sh db-backup     # Backup SQLite database
```

### Make (Alternative)

```bash
make dev          # Start development environment
make dev-detached # Start development (background)
make prod         # Start production environment
make build        # Build all images
make build-dev    # Build development images
make build-prod   # Build production images (no cache)
make clean        # Remove containers and volumes
make logs         # View all logs
make logs-api     # View API logs
make logs-client  # View client logs
make stop         # Stop all containers
make restart      # Restart services
make status       # Show container status
make health       # Check service health
make shell-api    # Open API container shell
make shell-client # Open client container shell
make db-backup    # Backup SQLite database
```

### Raw Docker Compose

```bash
# Development
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build -d

# Stop all
docker compose down

# View logs
docker compose logs -f

# Remove everything including volumes
docker compose down -v --remove-orphans
```

## ⚙️ Configuration

### Environment Variables

Copy the template and configure:

```bash
cp env.example .env
```

Key variables:

| Variable       | Description                          | Default                                |
| -------------- | ------------------------------------ | -------------------------------------- |
| `SECRET_KEY`   | API security key (required for prod) | `change-me...`                         |
| `DATABASE_URL` | Database connection string           | `sqlite:///./server_data/surginote.db` |
| `LOG_LEVEL`    | Logging level                        | `INFO`                                 |
| `VITE_API_URL` | Frontend API endpoint                | `http://localhost:8001`                |
| `NODE_ENV`     | Node environment                     | `development`                          |

## 🔄 Development Features

### Hot Reloading

Both services support hot reloading in development mode:

- **Frontend**: Vite HMR (Hot Module Replacement)
- **Backend**: Uvicorn with `--reload` flag

Source code is mounted as volumes, so changes are reflected immediately.

### Volume Mounts (Development)

| Host Path                        | Container Path     | Purpose         |
| -------------------------------- | ------------------ | --------------- |
| `./surginote-client/src`         | `/app/src`         | Frontend source |
| `./surginote-client/public`      | `/app/public`      | Static assets   |
| `./surginote-server`             | `/app`             | Backend source  |
| `./surginote-server/server_data` | `/app/server_data` | Database        |

## 🏭 Production Features

### Multi-Stage Builds

Both Dockerfiles use multi-stage builds:

- **API**: Python deps compiled in builder, copied to slim runtime image
- **Client**: Built with Node, served by Nginx

### Security

- Non-root user execution
- Security headers via Nginx
- Resource limits (CPU/Memory)
- Read-only root filesystem (where possible)

### Optimizations

- Gzip compression for static assets
- 1-year cache headers for versioned assets
- Log rotation (max 10MB, 3 files)
- Health checks for automatic recovery

## 💾 Data Persistence

Named volumes preserve data across container restarts:

| Volume                     | Purpose             |
| -------------------------- | ------------------- |
| `surginote-api-data`       | SQLite database     |
| `surginote-api-videos`     | Uploaded videos     |
| `surginote-api-profiles`   | User profile images |
| `surginote-api-recordings` | Voice recordings    |

To backup the database:

```bash
make db-backup

# Or manually
docker compose exec surginote-api cp /app/server_data/surginote.db /app/server_data/backup.db
```

## 🐛 Troubleshooting

### Common Issues

**Port already in use:**

```bash
# Find process using port 8001
lsof -i :8001

# Kill process (replace PID)
kill -9 <PID>
```

**Container won't start:**

```bash
# Check logs
docker compose logs surginote-api
docker compose logs surginote-client

# Rebuild from scratch
docker compose down -v
docker system prune -f
docker compose up --build
```

**Hot reload not working (Windows):**
The Vite config includes `usePolling: true` which should fix this. If issues persist:

1. Ensure Docker Desktop has file sharing enabled for your drive
2. Try running Docker Desktop as Administrator

**Database migration issues:**

```bash
# Access API container
docker compose exec surginote-api /bin/bash

# Run migrations manually
alembic upgrade head
```

## 📦 Local Development (Without Docker)

### Backend

```bash
cd surginote-server
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

### Frontend

```bash
cd surginote-client
npm install
npm run dev
```

## 📄 License

Part of the SurgiNote project.
