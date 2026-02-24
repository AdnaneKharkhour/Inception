FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/portainer/portainer/releases/download/2.17.1/portainer-2.17.1-linux-amd64.tar.gz

RUN tar -xvzf portainer-2.17.1-linux-amd64.tar.gz && \
    mv portainer/portainer /usr/local/bin/ && \
    rm -rf portainer* &&  \
    mkdir -p /data

RUN curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

EXPOSE 9001

CMD [ "/usr/local/bin/portainer" ]