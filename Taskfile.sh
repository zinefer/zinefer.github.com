#!/bin/bash

function build {
    hugo --minify

    # Sometimes the spookfest.js is missing (some wsl issue im sure) so test for it here
    if cat public/index.html | grep -q spookfest ; then
        echo "Spookfest included"
    else
        echo "Spookfest not found"
        exit 1
    fi    
}

function deploy {
    build
    rsync -azvhe ssh --delete --progress public/* jameskiefer.com:/var/www/jameskiefer/
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}