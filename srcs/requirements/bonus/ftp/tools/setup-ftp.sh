#!/bin/bash

set -e

mkdir -p /var/www/html

#Check ftpuser 

if [! id "${FTP_USER}" &> /dev/null]; then
    useradd -m -d /var/www/html -s /bin/bash ${FTP_USER}
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    chown -R ${FTP_USER}:${FTP_USER} /var/www/html
    chmod -R 755 /var/www/html
    echo "Created"
else
    echo "Already Created"
fi

exec "$@"