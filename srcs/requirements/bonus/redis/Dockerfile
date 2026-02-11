FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/lib/redis && \
    chmod 755 /var/lib/redis
    
COPY conf/redis.conf /etc/redis/redis.conf

WORKDIR /var/lib/redis

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]