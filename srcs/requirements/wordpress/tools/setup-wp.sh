#!/bin/bash

set -e

until mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1" &> /dev/null; do
  echo "Waiting for MariaDB ..."
  sleep 2
done
echo "MariaDB is up"

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Setting up WordPress"
    wp core download --allow-root

    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root
    wp core install \
        --url=${DOMAIN_NAME} \
        --title="inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root
    wp user create ${WP_USER} \
        ${WP_USER_EMAIL} \
        --user_pass=${WP_USER_PASSWORD} \
        --role=author \
        --allow-root
    echo "WordPress setup completed"
else
    echo "WordPress is already set up"
fi

chown -R www-data:www-data /var/www/html

exec "$@"