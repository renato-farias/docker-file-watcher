#!/bin/bash

set -eo pipefail

if [[ -z ${PROJECT_NAME} ]]; then
    PROJECT_NAME=$(docker inspect $HOSTNAME |jq -r '.[0].Config.Labels."com.docker.compose.project"')
fi

DIR_TO_WATCH="/watch"
CONFIG_FILE="/tmp/docker-file-watcher.config"
DOCKER_UNIX_SOCK=unix:///var/run/docker.sock
INOTIFY_EVENTS_DEFAULT="create,delete,modify,move"
INOTIFY_OPTONS_DEFAULT="--monitor --recursive"

echo "Config:"
cat ${CONFIG_FILE}
echo ""

echo "[Starting inotifywait...]"
inotifywait -e ${INOTIFY_EVENTS_DEFAULT} ${INOTIFY_OPTONS_DEFAULT} ${DIR_TO_WATCH} | \
    while read -r notifies;
    do
    	echo "$notifies"
        INOTIFY_DIR=$(awk -F' ' '{print $1}' <<< $notifies)
        INOTIFY_EVENT=$(awk -F ' ' '{print $2}' <<< $notifies)
        INOTIFY_FILE=$(cut -f 3- -d' ' <<< $notifies)

        SERVICES_TO_RELOAD=()

        IFS='
'

        for line in $(cat ${CONFIG_FILE}); do
            CONFIG_SERVICE=$(awk -F' ' '{print $1}' <<< $line)
            CONFIG_REGEXP=$(cut -f 2- -d' ' <<<  $line)

            if [[ ${INOTIFY_FILE} =~ ${CONFIG_REGEXP} ]]; then
                SERVICES_TO_RELOAD+=(${CONFIG_SERVICE})
            fi
        done

        if [ ${#SERVICES_TO_RELOAD[@]} -eq 0 ]; then
            echo "No services to restart"
        else
            echo "retarting services ${SERVICES_TO_RELOAD[@]}"
            docker-compose --project-name ${PROJECT_NAME} restart ${SERVICES_TO_RELOAD[@]}
        fi

    done
