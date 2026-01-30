NAME          = inception
DOCKER_COMPOSE = docker compose -f ./srcs/docker-compose.yml
# Use the current user's home to make it portable
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

clean:
	@echo "$(YELLOW)[INFO]$(RESET) Removing containers and project volumes..."
	@$(DOCKER_COMPOSE) down -v
	@echo "$(GREEN)[OK]$(RESET) Project volumes deleted."

fclean: clean
	@echo "$(RED)[WARN]$(RESET) Executing deep clean..."
	@sudo bash ./tools/util.sh --clear
	@docker system prune -af
	@echo "$(GREEN)[OK]$(RESET) Entire environment wiped."

re: fclean all

.PHONY: all init up down clean fclean re