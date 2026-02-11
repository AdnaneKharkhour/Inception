#!/bin/bash

set -e

mkdir -p /var/www/html

#Check ftpuser 

if ! id -u ${FTP_USER} > /dev/null 2>&1; then
    useradd -m -d /var/www/html -s /bin/bash ${FTP_USER}
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    echo "DONE"
else
    echo "FTP user already exists."
fi

chown -R ${FTP_USER}:${FTP_USER} /var/www/html
chmod -R 755 /var/www/html

exec "$@"