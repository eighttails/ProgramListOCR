#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
cd $SCRIPT_DIR

pip install --user pillow
./download_dataset.sh

# cp -r ../training/tessdata .
# cp ../training/tessdata_out/* tessdata
mkdir tessdata_finetuned 2> /dev/null
cd tesstrain

LANGNAME=$1
FINAL_ITERATIONS=$2

rm -rf $PWD/../tessdata_finetuned/$LANGNAME

TESSDATA_PREFIX=$(which tesseract | sed -e 's|bin/tesseract|share/tessdata|') \
TESSDATA=$TESSDATA_PREFIX \
MODEL_NAME=$LANGNAME \
START_MODEL=$LANGNAME \
DATA_DIR=$PWD/../tessdata_finetuned \
GROUND_TRUTH_DIR=$PWD/../program_dataset/$LANGNAME \
MAX_ITERATIONS=$FINAL_ITERATIONS \
make -e training -j $(nproc)

