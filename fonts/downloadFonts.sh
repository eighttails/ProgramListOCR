#!/bin/bash
if [ "$MINGW_CHOST" != "" ]; then
    SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
fi

cd $SCRIPT_DIR

#DotMatrix
if [ ! -d $SCRIPT_DIR/DotMatrix-Regular ]; then
wget -c http://www.ffonts.net/DotMatrix-Regular.font.zip
unzip -d DotMatrix-Regular DotMatrix-Regular.font.zip
fi

#P6 TTF Font
if [ ! -d $SCRIPT_DIR/p6ttf ]; then
wget -c http://p6ers.net/hashi/archive/p6ttf.lzh
mkdir $SCRIPT_DIR/p6ttf
pushd p6ttf
lha x ../p6ttf.lzh
popd
fi

#VLGothic
if [ ! -d $SCRIPT_DIR/VLGothic ]; then
wget -c https://ja.osdn.net/dl/vlgothic/VLGothic-20141206.zip
unzip VLGothic-20141206.zip
fi

#TakaoFonts
if [ ! -d $SCRIPT_DIR/TakaoFonts_00303.01 ]; then
wget -c https://launchpad.net/takao-fonts/trunk/15.03/+download/TakaoFonts_00303.01.zip
unzip TakaoFonts_00303.01.zip
fi

#PixelMPlus
if [ ! -d $SCRIPT_DIR/PixelMplus-20130602 ]; then
wget -c https://ja.osdn.net/projects/mix-mplus-ipa/downloads/58930/PixelMplus-20130602.zip
unzip PixelMplus-20130602.zip
fi

#MSX Truetype Fonts
if [ ! -d $SCRIPT_DIR/MSX ]; then
mkdir $SCRIPT_DIR/MSX
pushd MSX
wget -c http://www.gigamix.jp/download/gigamix/MSXW40J.TTF
wget -c http://www.gigamix.jp/download/gigamix/MSXW32J.TTF
popd
fi

#Misaki fonts
if [ ! -d $SCRIPT_DIR/misaki_ttf_2015-04-10.zip ]; then
wget -c http://www.geocities.jp/littlimi/arc/misaki/misaki_ttf_2015-04-10.zip
unzip misaki_ttf_2015-04-10.zip
fi

