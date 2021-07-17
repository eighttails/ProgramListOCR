#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
cd $SCRIPT_DIR

# Usage: gdrive_download 123-abc ./output.zip
function gdrive_download() { 
    CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://drive.google.com/uc?export=download&id=$1" -O- | sed -En 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
    wget --load-cookies /tmp/cookies.txt "https://drive.google.com/uc?export=download&confirm=$CONFIRM&id=$1" -O $2
    rm -f /tmp/cookies.txt
}

if [ "$1" == "-f" ]; then
    rm -rf program_dataset*
fi

if [ ! -d program_dataset ]; then
    gdrive_download 1qbz5lbgfbn3upbpu0m3BLSqeQpBtecly program_dataset.tar.gz
    tar xf program_dataset.tar.gz
fi
