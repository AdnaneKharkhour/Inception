#!/bin/bash

set -e

filebrowser config init
filebrowser users add "${FB_USER}" "${FB_PASSWORD}" --perm.admin

exec "$@"