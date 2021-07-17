#!/bin/bash

GH='/usr/local/bin/gh'
BAD_WORDS=(cialis amoxicillin)
CONTENT_PATH='content'

function install {
    ./devops/scripts/install-hugo.sh
    npm install
}

function build {
    hugo --minify

    # Sometimes the spookfest.js is missing??
    if cat public/index.html | grep -q "spookfest.js" ; then
        echo "Spookfest included"
    else
        echo "Spookfest not found"
        exit 1
    fi
}

function wait-for {
    URL=${1?}
    CODE=${2:-200}

    start=$SECONDS

    timeout --foreground 300 bash \
	<<-EOD
		until [[ "\$RESP" == "$CODE" ]]; do 
            [[ \$RESP ]] && sleep 1
			RESP=\$(curl -sIL -o /dev/null -w '%{http_code}' $URL | tr -d '\n')
			echo -ne "\$RESP "
            TRIES=\$(( TRIES + 1 )) && [[ \$(( TRIES % 10 )) == 0 ]] && echo
        done
	EOD

    duration=$(( SECONDS - start ))
    RET=$?

    echo 

    if [[ $RET -eq 0 ]]; then
        echo "$URL returned $CODE in $duration seconds"
    else
        echo "$URL timed out after $duration waiting for $CODE"
        exit 1
    fi
}

function regression {
    ACTION=${1?}

    hugo serve -b host.docker.internal --bind 0.0.0.0 &
    wait-for localhost:1313

    curl -s http://localhost:1313/sitemap.xml \
        | npx sitemap --parse \
        | jq --slurp '. | map(.url) | sort' > devops/backstopjs/urls.json
    
    HOST_IP="$(ip route | grep -E '(default|docker0)' | grep -Eo '([0-9]+\.){3}[0-9]+' | tail -1)"
    ADD_HOST_FLAG="--add-host host.docker.internal:$HOST_IP"
    echo $ADD_HOST_FLAG

    docker run --rm -v $(pwd):/src $ADD_HOST_FLAG \
        backstopjs/backstopjs $ACTION --config=devops/backstopjs/main.js

    RET=$?
    kill %1
    exit $RET
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
    NAME=${1?}

    if [ -d "${CONTENT_PATH}/posts/${NAME}" ]; then
        VPATH="${CONTENT_PATH}/posts/${NAME}"
    elif [ -d "${CONTENT_PATH}/projects/${NAME}" ]; then
        VPATH="${CONTENT_PATH}/projects/${NAME}"
    fi

    for i in $VPATH/*.mp4; do 
        ffmpeg -y -i "$i" -c:v libx264 -crf 20 "${i%.*}_compress.mp4";
    done
}

function remove-extras {
    NAME=${1?}
    IGNORED="index.md thumb.jpg thumb.png"

    if [ -d "${CONTENT_PATH}/posts/${NAME}" ]; then
        VPATH="${CONTENT_PATH}/posts/${NAME}"
    elif [ -d "${CONTENT_PATH}/projects/${NAME}" ]; then
        VPATH="${CONTENT_PATH}/projects/${NAME}"
    fi

    mkdir "${VPATH}/unused"

    for i in $VPATH/*; do

        local FILE="${i##*/}"

        if [[ " $IGNORED " =~ .*\ $FILE\ .* ]] || [ -d "${i}" ]; then
            continue;
        fi

        if ! grep -q "${FILE%.*}" "${VPATH}/index.md"; then
            mv "${i}" "${VPATH}/unused"
        fi

    done
}

function new {
    TYPE=${1?}
    NAME=${2}

    if [ ! -d "${CONTENT_PATH}/${TYPE}" ]; then
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