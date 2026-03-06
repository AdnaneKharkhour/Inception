#!/bin/bash

set -e


if [ ! -f "/filebrowser.db" ];then
    filebrowser config init
    filebrowser users add "${FB_USER}" "${FB_PASSWORD}" --perm.admin
    echo "Created"
else
    echo "Already created"
fi

exec "$@"