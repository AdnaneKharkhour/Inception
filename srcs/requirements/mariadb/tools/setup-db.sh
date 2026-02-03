#!/bin/bash
set -e

#Check if DB directory exists

if [ ! -d "/var/lib/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

#The root user can only connect from the localhost
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

#The user can connect from any host (%)
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

#Save changes
FLUSH PRIVILEGES;

EOF

    echo "MariaDB setup completed."
else
    echo "MariaDB already initialized."
fi

#Replace script with the original CMD (mysqld) 
exec "$@"