#!/bin/bash 
function exitOnError(){
if [ $? -ne 0 ]; then
    echo "ERROR."
    exit 1
else
    echo "SUCCESS."
fi
}

if [ "$MINGW_CHOST" != "" ]; then
    SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
fi

mkdir -p $SCRIPT_DIR/tessdata_out
mkdir -p $SCRIPT_DIR/tessdata_tmp/bas

export PANGOCAIRO_BACKEND=fc 

if [ ! -e $SCRIPT_DIR/tessdata_tmp/bas/bas.unicharset ]; then
export TEXT2IMAGE_EXTRA_ARGS=""
./tesstrain.sh \
--fonts_dir $SCRIPT_DIR/../fonts \
--lang bas \
--linedata_only \
--noextract_font_properties \
--exposures "0 2 4 6 -2 -4 -6 -8 -10 -12" \
--char_spacings "0.0 0.7 1.4" \
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

if [ ! -e $SCRIPT_DIR/tessdata_tmp/bas_checkpoint ]; then
combine_tessdata -e $SCRIPT_DIR/tessdata/eng.traineddata \
$SCRIPT_DIR/tessdata/eng.lstm 
exitOnError

lstmtraining \
--old_traineddata $SCRIPT_DIR/tessdata/eng.traineddata \
--continue_from $SCRIPT_DIR/tessdata/eng.lstm \
--traineddata $SCRIPT_DIR/tessdata_tmp/bas/bas.traineddata \
--debug_interval -1 \
--perfect_sample_delay 10 \
--model_output $SCRIPT_DIR/tessdata_tmp/bas \
--train_listfile $SCRIPT_DIR/tessdata_tmp/bas.training_files.txt \
--max_iterations=1000
exitOnError


else

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/bas/bas.traineddata \
--continue_from $SCRIPT_DIR/tessdata_tmp/bas_checkpoint \
--model_output $SCRIPT_DIR/tessdata_out/bas.traineddata \
--stop_training
exitOnError


START=$(date +%s)

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/bas/bas.traineddata \
--debug_interval -1 \
--perfect_sample_delay 10 \
--continue_from $SCRIPT_DIR/tessdata_tmp/bas_checkpoint \
--model_output $SCRIPT_DIR/tessdata_tmp/bas \
--train_listfile $SCRIPT_DIR/tessdata_tmp/bas.training_files.txt \
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


#lstmeval --model $SCRIPT_DIR/tessdata_tmp/bas/bas.lstm_checkpoint \
#--eval_listfile $SCRIPT_DIR/tessdata_tmp/bas/bas.training_files.txt


