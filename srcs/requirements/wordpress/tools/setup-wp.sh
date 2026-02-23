#!/bin/bash

set -e

until mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" &> /dev/null; do
  echo "Waiting for MariaDB ..."
  sleep 4
done
echo "MariaDB is up"

WP_PATH=/var/www/html

if [ ! -f ${WP_PATH}/wp-config.php ]; then
    echo "Setting up WordPress"
    
    rm -f ${WP_PATH}/index.nginx-debian.html
    wp core download --allow-root --path=${WP_PATH} --force

    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root \
        --path=${WP_PATH}
    wp core install \
        --url=${DOMAIN_NAME} \
        --title="inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root \
        --path=${WP_PATH}
    wp user create ${WP_USER} \
        ${WP_USER_EMAIL} \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author \
        --allow-root \
        --path=${WP_PATH}
    wp plugin install redis-cache --activate --allow-root --path=${WP_PATH}
    wp config set WP_REDIS_HOST redis --allow-root --path=${WP_PATH}
    wp config set WP_REDIS_PORT 6379 --raw --allow-root --path=${WP_PATH}
    echo "WordPress setup completed"
else
    echo "WordPress is already set up"
fi

chown -R www-data:www-data ${WP_PATH}

exec "$@"