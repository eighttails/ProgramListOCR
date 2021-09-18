#!/bin/bash 
if [ "$MINGW_CHOST" != "" ]; then
    SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
fi
cd $SCRIPT_DIR

./makeTessData.sh n6x 2000000

cd $SCRIPT_DIR/../finetuning
# ./finetune_n6x.sh

