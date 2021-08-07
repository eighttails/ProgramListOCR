#!/bin/bash 
if [ "$MINGW_CHOST" != "" ]; then
    SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
fi
cd $SCRIPT_DIR

LANGNAME=$1
MAX_ITERATIONS=10000
FINAL_ITERATIONS=$2

source common.sh
../fonts/downloadFonts.sh

mkdir -p $SCRIPT_DIR/tessdata_out
mkdir -p $SCRIPT_DIR/tessdata_tmp/${LANGNAME}

export PANGOCAIRO_BACKEND=fc
FONTS_DIR=$SCRIPT_DIR/../fonts
export TESSDATA_PREFIX=$(which tesseract | sed -e 's|bin/tesseract|share/tessdata|')

if [ ! -e $SCRIPT_DIR/tessdata_tmp/${LANGNAME}/${LANGNAME}.unicharset ]; then
export TEXT2IMAGE_EXTRA_ARGS=""
./tesstrain.py \
--fonts_dir $FONTS_DIR \
--ptsize 12 \
--lang ${LANGNAME} \
--linedata_only \
--distort_image \
--noextract_font_properties \
--langdata_dir $SCRIPT_DIR/langdata \
--tessdata_dir $TESSDATA_PREFIX \
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


while :
do

if [ ! -e $SCRIPT_DIR/tessdata_tmp/${LANGNAME}_checkpoint ]; then
dos2unix $SCRIPT_DIR/tessdata_tmp/${LANGNAME}.training_files.txt

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/${LANGNAME}/${LANGNAME}.traineddata \
--debug_interval -1 \
--net_spec '[1,0,0,1 Ct5,5,16 Mp3,3 Lfys64 Lfx128 Lrx128 Lfx256 O1c105]' \
--perfect_sample_delay 10 \
--model_output $SCRIPT_DIR/tessdata_tmp/${LANGNAME} \
--train_listfile $SCRIPT_DIR/tessdata_tmp/${LANGNAME}.training_files.txt \
--max_iterations=1000
exitOnError

# --net_spec '[1,48,0,1 Ct3,3,16 Mp3,3 Lfys64 Lfx96 Lrx96 Lfx512 O1c1]' \

else

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/${LANGNAME}/${LANGNAME}.traineddata \
--continue_from $SCRIPT_DIR/tessdata_tmp/${LANGNAME}_checkpoint \
--model_output $SCRIPT_DIR/tessdata_out/${LANGNAME}.traineddata \
--stop_training
exitOnError

cp $SCRIPT_DIR/tessdata_out/${LANGNAME}.traineddata $TESSDATA_PREFIX

START=$(date +%s)

lstmtraining \
--traineddata $SCRIPT_DIR/tessdata_tmp/${LANGNAME}/${LANGNAME}.traineddata \
--debug_interval -1 \
--perfect_sample_delay 10 \
--continue_from $SCRIPT_DIR/tessdata_tmp/${LANGNAME}_checkpoint \
--model_output $SCRIPT_DIR/tessdata_tmp/${LANGNAME} \
--train_listfile $SCRIPT_DIR/tessdata_tmp/${LANGNAME}.training_files.txt \
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

if [ $MAX_ITERATIONS -ge $FINAL_ITERATIONS ]; then
    echo Training completed.
    exit 0
fi

fi
done


#lstmeval --model $SCRIPT_DIR/tessdata_tmp/${LANGNAME}/${LANGNAME}.lstm_checkpoint \
#--eval_listfile $SCRIPT_DIR/tessdata_tmp/${LANGNAME}/${LANGNAME}.training_files.txt


