#!/bin/bash 
if [ "$MINGW_CHOST" != "" ]; then
    SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
fi
cd $SCRIPT_DIR

./makeTessData.sh hex 700000

cd $SCRIPT_DIR/../finetuning
./finetune_hex.sh
