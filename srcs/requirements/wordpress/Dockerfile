FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-mbstring \
    php7.4-xml \
    curl \
    mariadb-client \
    php7.4-redis \
    && rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY tools/setup-wp.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup-wp.sh && \
    mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php

EXPOSE 9000

ENTRYPOINT [ "setup-wp.sh" ]

CMD [ "php-fpm7.4", "-F" ]