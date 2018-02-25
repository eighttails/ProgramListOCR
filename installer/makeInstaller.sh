#!/bin/bash 
SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))

#Qt Installer Frameworkをインストール
pacman -S --needed --noconfirm \
    $MINGW_PACKAGE_PREFIX-ntldd-git \
    $MINGW_PACKAGE_PREFIX-qt-installer-framework-git

rm -rf $SCRIPT_DIR/worktree 2> /dev/null
cp -r $SCRIPT_DIR/skeleton $SCRIPT_DIR/worktree
PRODUCTDATA=$SCRIPT_DIR/worktree/packages/org.eithttails.programlistocr/data
mkdir -p $PRODUCTDATA/bin

#READMEをコピー
cp $SCRIPT_DIR/../README.html $PRODUCTDATA

#インストーラー作成作業ディレクトリにgImageReaderをビルド
GIMAGEREADER_PREFIX=$PRODUCTDATA $SCRIPT_DIR/../setup/MSYS2Private/gimagereader/gimagereader.sh

#Qtの依存ライブラリを集約する
windeployqt --release $PRODUCTDATA/bin/gimagereader-qt5.exe

#Qt以外の依存ライブラリを集約する
ntldd -R $PRODUCTDATA/bin/gimagereader-qt5.exe | sed "s|\\\|/|g" | grep "$(cygpath -am $MINGW_PREFIX)/" | sed -e "s/^.*=> \(.*\) .*/\1/" | xargs -I{} cp {} $PRODUCTDATA/bin/

#学習済み言語データをコピー
cp -r $SCRIPT_DIR/../training/tessdata_out $PRODUCTDATA/share/tessdata

#インストーラーをビルド
cd $SCRIPT_DIR/worktree
binarycreator -v -f -c config/config.xml -p packages ../ProgramListOCRSetup.exe 

