#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
cd $SCRIPT_DIR

./finetune.sh n6x 2000000
