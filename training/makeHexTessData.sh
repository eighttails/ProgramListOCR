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

mkdir -p $SCRIPT_DIR/tessdata
mkdir -p $SCRIPT_DIR/tessdata_tmp/hex

export PANGOCAIRO_BACKEND=fc 

if [ ! -e $SCRIPT_DIR/tessdata_tmp/hex/hex.unicharset ]; then
./tesstrain.sh \
--fonts_dir $SCRIPT_DIR/../fonts \
--lang hex \
--linedata_only \
--noextract_font_properties \
--exposures "-5 -3 -1 0 1 3" \
--langdata_dir $SCRIPT_DIR/langdata \
--tessdata_dir $SCRIPT_DIR/tessdata_in \
--output_dir $SCRIPT_DIR/tessdata_tmp 
  
exitOnError

fi

export SCROLLVIEW_PATH=$SCRIPT_DIR/../java
export PATH=$(cygpath -u "$JAVA_HOME/bin"):$PATH
export JAVA_TOOL_OPTIONS=-Duser.language=en

while :
do

if [ ! -e $SCRIPT_DIR/tessdata_tmp/hex_checkpoint ]; then
combine_tessdata -e $SCRIPT_DIR/tessdata_in/eng.traineddata \
$SCRIPT_DIR/tessdata_in/eng.lstm 
exitOnError

lstmtraining \
--old_traineddata $SCRIPT_DIR/tessdata_in/eng.traineddata \
--continue_from $SCRIPT_DIR/tessdata_in/eng.lstm \
--traineddata $SCRIPT_DIR/tessdata_tmp/hex/hex.traineddata \
--debug_interval -1 \
--net_spec '[1,36,0,1 Ct3,3,16 Mp3,3 Lfys48 Lfx96 Lrx96 Lfx256 O1c111]' \
--learning_rate 20e-4 \
--model_output $SCRIPT_DIR/tessdata_tmp/hex \
--train_listfile $SCRIPT_DIR/tessdata_tmp/hex.training_files.txt \
--max_iterations 10000
exitOnError

else

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/hex/hex.traineddata \
--continue_from $SCRIPT_DIR/tessdata_tmp/hex_checkpoint \
--model_output $SCRIPT_DIR/tessdata/hex.traineddata \
--stop_training
exitOnError


lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/hex/hex.traineddata \
--debug_interval -1 \
--continue_from $SCRIPT_DIR/tessdata_tmp/hex_checkpoint \
--model_output $SCRIPT_DIR/tessdata_tmp/hex \
--train_listfile $SCRIPT_DIR/tessdata_tmp/hex.training_files.txt \
--max_iterations 10000
exitOnError
fi

done


#lstmeval --model $SCRIPT_DIR/tessdata_tmp/hex/hex.lstm_checkpoint \
#--eval_listfile $SCRIPT_DIR/tessdata_tmp/hex/hex.training_files.txt


