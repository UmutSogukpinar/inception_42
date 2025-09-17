NAME=inception

all: up

up:
	docker compose -f ./srcs/docker-compose.yml up -d --build

down:
	docker compose -f ./srcs/docker-compose.yml down

clean:
	docker compose -f ./srcs/docker-compose.yml down -v

fclean: clean volume-clean
	docker system prune -af --volumes

volume-clean:
	sudo rm -rf /home/umut/data/wordpress/*
	sudo rm -rf /home/umut/data/mariadb/*

re: fclean all

.PHONY : all up down clean fclean volume-clean re