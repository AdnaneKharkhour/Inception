FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    wget \
    adduser \
    libfontconfig1 \
    musl \
    && rm -rf /var/lib/apt/lists/*

RUN wget -o wget https://dl.grafana.com/grafana-enterprise/release/12.4.0/grafana-enterprise_12.4.0_22325204712_linux_amd64.deb && \
    dpkg -i grafana-enterprise_12.4.0_22325204712_linux_amd64.deb && \
    rm -f grafana-enterprise_12.4.0_22325204712_linux_amd64.deb

WORKDIR /usr/share/grafana

EXPOSE 3000


CMD ["grafana-server"]