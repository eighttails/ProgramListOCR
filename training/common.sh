#!/bin/bash 

function exitOnError(){
if [ $? -ne 0 ]; then
    echo "ERROR."
    exit 1
else
    echo "SUCCESS."
fi
}

if [ "$MINGW_CHOST" != "" ]; then
    SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
    pacman -S --noconfirm --needed $MINGW_PACKAGE_PREFIX-python-pip
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
fi

pip3 install --user tqdm psutil

cd $SCRIPT_DIR
../fonts/downloadFonts.sh

