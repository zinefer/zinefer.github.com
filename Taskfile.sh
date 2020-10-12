#!/bin/bash

GH='/usr/local/bin/gh'
BAD_WORDS=(cialis amoxicillin)

function install {
    ./devops/scripts/install-hugo.sh
    npm install --prefix themes/carbon
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

    hugo serve -b host.docker.internal &
    wait-for localhost:1313
    
    if ip addr show docker0; then
        HOST_IP="$(ip addr show docker0 | grep -Po 'inet \K[\d.]+')"
        ADD_HOST_FLAG="--add-host host.docker.internal:$HOST_IP"
    fi

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