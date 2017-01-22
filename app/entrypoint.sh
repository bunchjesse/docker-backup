#!/bin/bash

while :
do
    curtime=$(date '+%H%M')
    echo "Current time is $curtime, looking for $RUNTIME."
    if [[ $curtime = $RUNTIME ]]
    then
        echo "Running backup..."
        ./backup.sh
    fi
    sleep 60
done

