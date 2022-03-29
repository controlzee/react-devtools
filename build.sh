#!/usr/bin/env bash

USER_ID=${USER_ID:-$(id -u)}
GROUP_ID=${GROUP_ID:-$(id -g)}
BB_USERNAME=${BB_USERNAME:-${USER}}

# write those files
echo "USER_ID=${USER_ID}" > .env
echo "GROUP_ID=${GROUP_ID}" >> .env
echo "USERNAME=$(whoami)" >> .env

docker-compose build
docker-compose run build