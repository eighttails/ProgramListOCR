#!/bin/bash
SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))

cd $SCRIPT_DIR

../fonts/downloadFonts.sh

./MSYS2Private/gimagereader/gimagereader.sh
