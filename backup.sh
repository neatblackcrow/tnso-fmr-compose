#!/bin/bash

read -p 'Before backing up, are you already shut down the Mariadb gracefully? ("y" to continue): ' confirm
if [ $confirm != 'y' ]; then
    exit 0
fi

CURRENT_DATETIME=$(date '+%d-%m-%Y-%H-%M-%p')
mkdir -p "./backups/$CURRENT_DATETIME"

# docker container cp -a fmr-mysql:/var/lib/mysql/ "./backups/$CURRENT_DATETIME"
cp -a ./persistent-data/mariadb/ ./backups/$CURRENT_DATETIME/
