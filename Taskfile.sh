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
    RESOURCE_GROUP=`az storage account show -n $STORAGE_ACCOUNT | jq -r .resourceGroup`
    PROFILE_NAME=`az cdn profile list -g $RESOURCE_GROUP | jq -r .[0].name`
    CDN_ENDPOINT=`az cdn endpoint list -g $RESOURCE_GROUP --profile-name $PROFILE_NAME | jq -r .[0].name`
    azcopy_v10 sync --delete-destination=true --recursive public $DEST
    az cdn endpoint purge -n $CDN_ENDPOINT --profile-name $PROFILE_NAME --content-paths "/*" --resource-group $RESOURCE_GROUP --no-wait
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

function compress-videos {
    for i in content/posts/$1/*.mp4; do 
        ffmpeg -y -i "$i" -c:v libx264 -crf 20 "${i%.*}_compress.mp4";
    done
}

function new {
    TYPE=${1?}
    NAME=${2}

    if [ ! -d "content/$TYPE" ]; then
        NAME=$TYPE
        TYPE=posts
    fi

    NAME=`echo $NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-'`

    hugo new $TYPE/$NAME/index.md
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time "${@:-help}"