FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    build-essential \
    tcl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

RUN wget -O redis-7.2.4.tar.gz https://github.com/redis/redis/archive/refs/tags/7.2.4.tar.gz && \
    tar xvf redis-7.2.4.tar.gz && \
    rm redis-7.2.4.tar.gz && \
    cd /usr/src/redis-7.2.4 && \
    make && make install

COPY conf/redis.conf /etc/redis/redis.conf

WORKDIR /var/lib/redis

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]