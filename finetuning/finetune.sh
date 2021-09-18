#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
cd $SCRIPT_DIR

pip install --user pillow
./download_dataset.sh

mkdir tessdata_finetuned 2> /dev/null
cd tesstrain

LANGNAME=$1
FINAL_ITERATIONS=$2


if [ "$MSYSTEM" != "" ];then
export TESSDATA_PREFIX=$(which tesseract | sed -e 's|bin/tesseract|bin/tessdata|')
else
export TESSDATA_PREFIX=$(which tesseract | sed -e 's|bin/tesseract|share/tessdata|')
fi
export TESSDATA=$TESSDATA_PREFIX
export MODEL_NAME=$LANGNAME
export START_MODEL=$LANGNAME
export DATA_DIR=$PWD/../tessdata_finetuned
export GROUND_TRUTH_DIR=$PWD/../program_dataset/$LANGNAME
export MAX_ITERATIONS=$FINAL_ITERATIONS

rm -rf $DATA_DIR/$LANGNAME

# train,evalのファイルリストを作成
make -e lists -j $(nproc)

# 学習用生成データファイルリストと結合
TEMP_TRAIN_LIST=$(mktemp)
cat $PWD/../../training/tessdata_tmp/$LANGNAME.training_files.txt $GROUND_TRUTH_DIR/list.train | shuf > $TEMP_TRAIN_LIST
mv -f $TEMP_TRAIN_LIST $DATA_DIR/$LANGNAME/list.train

# 学習開始
make -e training -j $(nproc)

