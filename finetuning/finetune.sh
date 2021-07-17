#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
cd $SCRIPT_DIR

pip install --user pillow

cp -r ../training/tessdata .
cp ../training/tessdata_out/* tessdata
mkdir tessdata_finetuned 2> /dev/null
cd tesstrain

LANGNAME=$1
FINAL_ITERATIONS=$2

rm -rf $PWD/../tessdata_finetuned/$LANGNAME

TESSDATA_PREFIX=$PWD/../tessdata \
TESSDATA=$PWD/../tessdata \
MODEL_NAME=$LANGNAME \
START_MODEL=$LANGNAME \
DATA_DIR=$PWD/../tessdata_finetuned \
GROUND_TRUTH_DIR=$PWD/../program_dataset/$LANGNAME \
MAX_ITERATIONS=$FINAL_ITERATIONS \
make -e training -j $(nproc)
