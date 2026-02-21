FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/* /var/www/html/*

COPY tools/* /var/www/html/


EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]