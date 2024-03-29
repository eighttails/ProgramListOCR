#!/bin/bash 
if [ "$MINGW_CHOST" != "" ]; then
    SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
fi

cd $SCRIPT_DIR
source common.sh
../fonts/downloadFonts.sh

mkdir -p $SCRIPT_DIR/tessdata_out
mkdir -p $SCRIPT_DIR/tessdata_tmp/n6x

export PANGOCAIRO_BACKEND=fc
FONTS_DIR=$SCRIPT_DIR/../fonts

if [ ! -e $SCRIPT_DIR/tessdata_tmp/jpn/jpn.unicharset ]; then
export TEXT2IMAGE_EXTRA_ARGS=""
./tesstrain.py \
--fonts_dir $FONTS_DIR \
--lang jpn \
--linedata_only \
--distort_image \
--noextract_font_properties \
--langdata_dir $SCRIPT_DIR/langdata \
--tessdata_dir $SCRIPT_DIR/tessdata \
--output_dir $SCRIPT_DIR/tessdata_tmp 

  
exitOnError

fi

export SCROLLVIEW_PATH=$SCRIPT_DIR/../java
if [ "$MINGW_CHOST" != "" ]; then
export PATH=$(cygpath -u "$JAVA_HOME/bin"):$PATH
else
export PATH=$JAVA_HOME/bin:$PATH
fi
export JAVA_TOOL_OPTIONS=-Duser.language=en

MAX_ITERATIONS=10000

while :
do

if [ ! -e $SCRIPT_DIR/tessdata_tmp/jpn_checkpoint ]; then
combine_tessdata -e $SCRIPT_DIR/tessdata/jpn.traineddata \
$SCRIPT_DIR/tessdata/jpn.lstm 
exitOnError

dos2unix $SCRIPT_DIR/tessdata_tmp/jpn.training_files.txt

lstmtraining \
--old_traineddata $SCRIPT_DIR/tessdata/jpn.traineddata \
--continue_from $SCRIPT_DIR/tessdata/jpn.lstm \
--traineddata $SCRIPT_DIR/tessdata_tmp/jpn/jpn.traineddata \
--debug_interval -1 \
--reset_learning_rate \
--perfect_sample_delay 10 \
--model_output $SCRIPT_DIR/tessdata_tmp/jpn \
--train_listfile $SCRIPT_DIR/tessdata_tmp/jpn.training_files.txt \
--max_iterations=1000
exitOnError


else

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/jpn/jpn.traineddata \
--continue_from $SCRIPT_DIR/tessdata_tmp/jpn_checkpoint \
--model_output $SCRIPT_DIR/tessdata_out/jpn.traineddata \
--stop_training
exitOnError


START=$(date +%s)

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/jpn/jpn.traineddata \
--debug_interval -1 \
--perfect_sample_delay 10 \
--continue_from $SCRIPT_DIR/tessdata_tmp/jpn_checkpoint \
--model_output $SCRIPT_DIR/tessdata_tmp/jpn \
--train_listfile $SCRIPT_DIR/tessdata_tmp/jpn.training_files.txt \
--max_iterations=$MAX_ITERATIONS
exitOnError

END=$(date +%s)
DIFF=$((END-START))

#すでに所定イテレーションに達していた場合すぐ終了するので、
#その場合はイテレーション数を増やしてやり直す
if [ $DIFF -le 30 ]; then
MAX_ITERATIONS=$(($MAX_ITERATIONS + 50000))
else
MAX_ITERATIONS=$(($MAX_ITERATIONS + 10000))
fi

fi

done


#lstmeval --model $SCRIPT_DIR/tessdata_tmp/jpn/jpn.lstm_checkpoint \
#--eval_listfile $SCRIPT_DIR/tessdata_tmp/jpn/jpn.training_files.txt


