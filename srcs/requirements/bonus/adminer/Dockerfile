FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php \
    php-mysqli \
    php-gd \
    php-zip \
    php-curl \
    php-xml \
    php-mbstring \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget -O adminer.zip https://www.adminer.org/latest.php && \
    unzip adminer.zip && rm adminer.zip

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]