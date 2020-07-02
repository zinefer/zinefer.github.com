#!/bin/bash

GH='/usr/local/bin/gh'
BAD_WORDS=(cialis amoxicillin)

function install {
    ./devops/scripts/install-hugo.sh

    npm install postcss-cli
    npm install autoprefixer
    npm install postcss-easing-gradients
}

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
    STORAGE_ACCOUNT=${1?}
    DEST="https://$STORAGE_ACCOUNT.blob.core.windows.net/\$web"
    azcopy_v10 sync --delete-destination=true --recursive public $DEST
}

function clean-prs {
    PRS=( $(hub pr list -f "%I ") )

    for pr in ${PRS[*]}; do
        echo "Pull Request #$pr"
        for badword in ${BAD_WORDS[*]}; do
            if hub pr show $pr -f "%b" | grep -q -i $badword; then
                echo "  detected badword \"$badword\""
                echo "  marking spam and closing"
                hub issue update $pr -l spam --state closed
                echo "  deleting branch"
                git push --quiet origin --delete $(hub pr show $pr -f "%H")
                break
            fi
        done
    done
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}