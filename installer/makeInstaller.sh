#!/bin/bash 
SCRIPT_DIR=$(cygpath -am $(dirname $(readlink -f ${BASH_SOURCE:-$0})))

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

#Qt Installer Frameworkをインストール
#MSYS2の最新版でビルドしたインストーラーは動作しないので旧バージョンをインストールする。
#https://bugreports.qt.io/browse/QTIFW-1312
if [ "$(command -v binarycreator | wc -l)" == "0" ];then
    pushd /tmp
    QTIFW_PACKAGE=mingw-w64-$ARCH-qt-installer-framework-git-r2975.36059724-1-any.pkg.tar.xz
    wget -c https://sourceforge.net/projects/msys2/files/REPOS/MINGW/$ARCH/$QTIFW_PACKAGE
    pacman -U --needed --noconfirm $QTIFW_PACKAGE
    popd
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
    $MINGW_PACKAGE_PREFIX-asciidoctor
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
popd

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
binarycreator -v -f -c config/config.xml -p packages ../ProgramListOCRSetup-$BIT-$VERSION.exe 

