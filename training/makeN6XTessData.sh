#!/bin/bash 
function exitOnError(){
if [ $? -ne 0 ]; then
    echo "ERROR."
    exit 1
else
    echo "SUCCESS."
fi
}

SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))

mkdir -p $SCRIPT_DIR/tessdata_out
mkdir -p $SCRIPT_DIR/tessdata_tmp/n6x

export PANGOCAIRO_BACKEND=fc 

if [ ! -e $SCRIPT_DIR/tessdata_tmp/n6x/n6x.unicharset ]; then
./tesstrain.sh \
--fonts_dir $SCRIPT_DIR/../fonts \
--lang n6x \
--linedata_only \
--noextract_font_properties \
--exposures "-12 -10 -8 -6 -4 -2 0 2 4 6" \
--langdata_dir $SCRIPT_DIR/langdata \
--tessdata_dir $SCRIPT_DIR/tessdata \
--output_dir $SCRIPT_DIR/tessdata_tmp 
  
exitOnError

fi

export SCROLLVIEW_PATH=$SCRIPT_DIR/../java
export PATH=$(cygpath -u "$JAVA_HOME/bin"):$PATH
export JAVA_TOOL_OPTIONS=-Duser.language=en

MAX_ITERATIONS=10000

while :
do

if [ ! -e $SCRIPT_DIR/tessdata_tmp/n6x_checkpoint ]; then
combine_tessdata -e $SCRIPT_DIR/tessdata/jpn.traineddata \
$SCRIPT_DIR/tessdata/jpn.lstm 
exitOnError

lstmtraining \
--old_traineddata $SCRIPT_DIR/tessdata/jpn.traineddata \
--continue_from $SCRIPT_DIR/tessdata/jpn.lstm \
--traineddata $SCRIPT_DIR/tessdata_tmp/n6x/n6x.traineddata \
--debug_interval -1 \
--learning_rate 20e-4 \
--model_output $SCRIPT_DIR/tessdata_tmp/n6x \
--train_listfile $SCRIPT_DIR/tessdata_tmp/n6x.training_files.txt \
--max_iterations=1000
exitOnError


else

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/n6x/n6x.traineddata \
--continue_from $SCRIPT_DIR/tessdata_tmp/n6x_checkpoint \
--model_output $SCRIPT_DIR/tessdata_out/n6x.traineddata \
--stop_training
exitOnError


START=$(date +%s)

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/n6x/n6x.traineddata \
--debug_interval -1 \
--continue_from $SCRIPT_DIR/tessdata_tmp/n6x_checkpoint \
--model_output $SCRIPT_DIR/tessdata_tmp/n6x \
--train_listfile $SCRIPT_DIR/tessdata_tmp/n6x.training_files.txt \
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


#lstmeval --model $SCRIPT_DIR/tessdata_tmp/n6x/n6x.lstm_checkpoint \
#--eval_listfile $SCRIPT_DIR/tessdata_tmp/n6x/n6x.training_files.txt


