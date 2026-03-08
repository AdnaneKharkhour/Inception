SRC = srcs/docker-compose.yml
DATA_PATH = /home/akharkho/data


all: up

up: make_dirs
	docker-compose -f ${SRC} up -d --build

make_dirs:
	mkdir -p ${DATA_PATH}/mariadb
	mkdir -p ${DATA_PATH}/wordpress
	mkdir -p ${DATA_PATH}/grafana

down:
	docker-compose -f ${SRC} down

clean: down
	docker system prune -af
	docker volume prune -f

fclean: clean
	sudo rm -rf ${DATA_PATH}	

re: fclean all

.PHONY: all clean fclean