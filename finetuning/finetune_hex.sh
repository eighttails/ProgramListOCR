#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
cd $SCRIPT_DIR

./finetune.sh hex 1000000
