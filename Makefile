NAME          = inception
DOCKER_COMPOSE = docker compose -f ./srcs/docker-compose.yml

DATA_DIR      = $(HOME)/data

# Colors
GREEN  = \033[0;32m
BLUE   = \033[0;34m
YELLOW = \033[0;33m
RED    = \033[0;31m
RESET  = \033[0m

all: up

init:
	@echo "$(BLUE)[INFO]$(RESET) Initializing environment..."
	@bash ./tools/util.sh --init

up: init
	@echo "$(BLUE)[INFO]$(RESET) Building and starting containers..."
	@$(DOCKER_COMPOSE) up -d --build
	@echo "$(GREEN)[SUCCESS]$(RESET) Service is running at https:usogukpi.42.fr"

down:
	@echo "$(YELLOW)[INFO]$(RESET) Stopping containers..."
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)[OK]$(RESET) Containers stopped."

.PHONY: all init up down