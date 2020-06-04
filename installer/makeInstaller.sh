#!/bin/bash 
SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))
export PATH=$MINGW_PREFIX/local/bin:$PATH

if [ "$1" == "" ]; then
    VERSION="dev"
else
    VERSION=$1
fi

if [ "$MINGW_CHOST" = "i686-w64-mingw32" ]; then
    BIT='32bit'
    ARCH='i686'
else
    BIT='64bit'
    ARCH='x86_64'
fi


#pacmanのパッケージ取得オプション
PACMAN_INSTALL_OPTS=()
PACMAN_INSTALL_OPTS+=('-S')
PACMAN_INSTALL_OPTS+=('--needed')
PACMAN_INSTALL_OPTS+=('--noconfirm')
PACMAN_INSTALL_OPTS+=('--disable-download-timeout')
export PACMAN_INSTALL_OPTS
#依存ライブラリをインストール
pacman "${PACMAN_INSTALL_OPTS[@]}" \
    $MINGW_PACKAGE_PREFIX-ntldd \
    $MINGW_PACKAGE_PREFIX-asciidoctor \
    $MINGW_PACKAGE_PREFIX-qt-installer-framework \
    2>/dev/null
if [ $? -ne 0 ]; then
    echo "ERROR."
    exit 1
fi

rm -rf $SCRIPT_DIR/worktree 2> /dev/null
cp -r $SCRIPT_DIR/skeleton $SCRIPT_DIR/worktree
PRODUCTDATA=$SCRIPT_DIR/worktree/packages/org.eithttails.programlistocr/data
mkdir -p $PRODUCTDATA/bin
mkdir -p $PRODUCTDATA/share

#READMEを生成
pushd $PRODUCTDATA
asciidoctor $SCRIPT_DIR/../README.adoc -D .
asciidoctor $SCRIPT_DIR/../README_J.adoc -D .
popd

#インストーラー作成作業ディレクトリにgImageReaderをビルド
GIMAGEREADER_PREFIX=$PRODUCTDATA $SCRIPT_DIR/../setup/MSYS2Private/gimagereader/gimagereader.sh

#Qtの依存ライブラリを集約する
windeployqt $PRODUCTDATA/bin/gimagereader-qt5.exe

#Qt以外の依存ライブラリを集約する
ntldd -R $PRODUCTDATA/bin/gimagereader-qt5.exe | sed "s|\\\|/|g" | grep "$(cygpath -am $MINGW_PREFIX)/" | sed -e "s/^.*=> \(.*\) .*/\1/" | xargs -I{} cp {} $PRODUCTDATA/bin/

#学習済み言語データをコピー
cp -r $SCRIPT_DIR/../training/tessdata_out $PRODUCTDATA/share/tessdata
cp $SCRIPT_DIR/../training/tessdata/eng.traineddata $PRODUCTDATA/share/tessdata

#インストーラーをビルド
cd $SCRIPT_DIR/worktree
binarycreator -v -f -c config/config.xml -p packages ../ProgramListOCRSetup-$BIT-$VERSION.exe 

