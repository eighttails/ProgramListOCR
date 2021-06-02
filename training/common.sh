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
    pacman -S --noconfirm --needed \
        $MINGW_PACKAGE_PREFIX-python-pip \
        $MINGW_PACKAGE_PREFIX-python-psutil
    pip3 install --user tqdm 
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
    pip3 install --user tqdm psutil
fi

cd $SCRIPT_DIR
../fonts/downloadFonts.sh

