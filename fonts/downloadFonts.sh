#!/bin/bash
if [ "$MINGW_CHOST" != "" ]; then
    SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
else
    SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))
fi

cd $SCRIPT_DIR
#Go Mono
wget -c https://github.com/golang/image/raw/master/font/gofont/ttfs/Go-Mono.ttf

#Arcade-N
if [ ! -d $SCRIPT_DIR/Arcade-N ]; then
wget -c https://www.ffonts.net/Arcade-N.font.zip
unzip -d Arcade-N Arcade-N.font.zip
fi

#PET fonts
if [ ! -d $SCRIPT_DIR/Commodore-PET ]; then
wget -c https://www.ffonts.net/Commodore-PET.font.zip
unzip -d Commodore-PET Commodore-PET.font.zip
fi

#DotMatrix
if [ ! -d $SCRIPT_DIR/DotMatrix-Regular ]; then
wget -c http://www.ffonts.net/DotMatrix-Regular.font.zip
unzip -d DotMatrix-Regular DotMatrix-Regular.font.zip
fi

#Verily serif mono
if [ ! -d $SCRIPT_DIR/verily_serif_mono ]; then
wget -c https://dl.dafont.com/dl/?f=verily_serif_mono -O verily_serif_mono.zip
unzip -d verily_serif_mono verily_serif_mono.zip
fi

#GP4 LCD Font
if [ ! -d $SCRIPT_DIR/GP4_LCD ]; then
mkdir $SCRIPT_DIR/GP4_LCD
pushd GP4_LCD
wget --content-disposition http://www.fontsner.com/download/11753-6210d289d4d92b7ef45086e1bb8d7b14.ttf
popd
fi

#P6 TTF Font
if [ ! -d $SCRIPT_DIR/p6ttf ]; then
wget -c http://p6ers.net/hashi/archive/p6ttf.lzh
mkdir $SCRIPT_DIR/p6ttf
pushd p6ttf
lha x ../p6ttf.lzh
popd
fi

#Noto Sans
if [ ! -e $SCRIPT_DIR/NotoSansCJKjp-hinted.zip ]; then
wget -c https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip
unzip NotoSansCJKjp-hinted.zip -d NotoSans
fi

#Noto Serif
if [ ! -e $SCRIPT_DIR/NotoSerifCJKjp-hinted.zip ]; then
wget -c https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKjp-hinted.zip
unzip NotoSerifCJKjp-hinted.zip -d NotoSerif
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

#MSX Truetype Fonts
if [ ! -d $SCRIPT_DIR/DumpListEditorVer037MSX0305 ]; then
wget -c https://bugfire2009.ojaru.jp/DumpListEditorVer037MSX0305.zip
unzip DumpListEditorVer037MSX0305.zip
fi

#Misaki fonts
if [ ! -e $SCRIPT_DIR/misaki_ttf_2019-02-03a.zip ]; then
wget -c http://littlelimit.net/arc/misaki/misaki_ttf_2019-02-03a.zip
unzip misaki_ttf_2019-02-03a.zip -d Misaki
fi

#N-Font
if [ ! -e $SCRIPT_DIR/N-Font.zip ]; then
wget -c http://upd780c1.g1.xrea.com/pc-8001/bin/N-Font.zip
unzip N-Font.zip -d N-Font
fi
