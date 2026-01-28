NAME=inception

DATA_DIR=/home/umut/data

# ===== Colors =====
GREEN  = \033[0;32m
BLUE   = \033[0;34m
YELLOW = \033[0;33m
RED    = \033[0;31m
RESET  = \033[0m

all: up

init:
	@echo "$(BLUE)[INFO]$(RESET) Checking data directory..."
	@sh ./init.sh
	@echo "$(GREEN)[OK]$(RESET) Data directory ready: $(DATA_DIR)"

up: init
	@echo "$(BLUE)[INFO]$(RESET) Starting $(NAME) containers..."
	@docker compose -f ./srcs/docker-compose.yml up -d --build
	@echo "$(GREEN)[SUCCESS]$(RESET) $(NAME) is up and running"

down:
	@echo "$(YELLOW)[INFO]$(RESET) Stopping $(NAME) containers..."
	@docker compose -f ./srcs/docker-compose.yml down
	@echo "$(GREEN)[OK]$(RESET) Containers stopped"

clean:
	@echo "$(YELLOW)[INFO]$(RESET) Removing containers and volumes..."
	@docker compose -f ./srcs/docker-compose.yml down -v
	@echo "$(GREEN)[OK]$(RESET) Containers and volumes removed"

fclean: clean
	@echo "$(RED)[WARN]$(RESET) Pruning Docker system (all unused data)..."
	@docker system prune -af --volumes
	@echo "$(GREEN)[OK]$(RESET) Docker system fully cleaned"

re: fclean all

.PHONY: all up down clean fclean re init
