FRONTEND_DIR = ./web/default
FRONTEND_CLASSIC_DIR = ./web/classic
BACKEND_DIR = .

.PHONY: all build-frontend build-frontend-classic build-all-frontends start-backend dev dev-api dev-web dev-web-classic

all: build-all-frontends start-backend

build-frontend:
	@echo "Building default frontend..."
	@cd $(FRONTEND_DIR) && bun install && DISABLE_ESLINT_PLUGIN='true' VITE_REACT_APP_VERSION=$(cat ../../VERSION) bun run build

build-frontend-classic:
	@echo "Building classic frontend..."
	@cd $(FRONTEND_CLASSIC_DIR) && bun install && VITE_REACT_APP_VERSION=$(cat ../../VERSION) bun run build

build-all-frontends: build-frontend build-frontend-classic

build-backend:
	@echo "Building backend..."
	go build -ldflags "-s -w -X 'github.com/QuantumNous/new-api/common.Version=$(cat VERSION)'" -o new-api

build-backend-linux: 
	@echo "Building backend for Linux..."
	@cd $(BACKEND_DIR) && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w -X 'github.com/QuantumNous/new-api/common.Version=$(VERSION_VALUE)'" -o new-api-linux-amd64

start-backend:
	@echo "Starting backend dev server..."
	@cd $(BACKEND_DIR) && go run main.go &

dev-api:
	@echo "Starting backend services (docker)..."
	@docker compose -f docker-compose.dev.yml up -d

dev-web:
	@echo "Starting frontend dev server..."
	@cd $(FRONTEND_DIR) && bun install && bun run dev

dev-web-classic:
	@echo "Starting classic frontend dev server..."
	@cd $(FRONTEND_CLASSIC_DIR) && bun install && bun run dev

dev: dev-api dev-web


## 部署发布前端
publish-frontend: build-all-frontends
	@echo "Publishing frontend to server..."
	@rsync -avz --delete $(FRONTEND_DIR)/dist/ 38.76.162.78-heyunidc:~/code/new-api/$(FRONTEND_DIR)/dist/
	@rsync -avz --delete $(FRONTEND_CLASSIC_DIR)/dist/ 38.76.162.78-heyunidc:~/code/new-api/$(FRONTEND_CLASSIC_DIR)/dist/

## 部署发布后端
publish-backend: build-all-frontends build-backend-linux
	@echo "Publishing backend to server..."
# 	@rsync -avzurP new-api-linux-amd64 38.76.162.78-heyunidc:~/code/new-api/new-api
	@rsync -avzurP new-api-linux-amd64 dogyun:~/code/new-api/new-api
