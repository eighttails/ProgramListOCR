#!/bin/bash

#このスクリプトの置き場所
SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE:-$0}))

#バージョン番号
MAJOR=$1
MINOR=$2
PATCH=$3
PRE=$4

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
    echo usage $0 MAJOR MINOR PATCH [PRE]
    exit 1
fi 

#数字のみのバージョン
NUMVER=$MAJOR.$MINOR.$PATCH

#プレリリース(alpha,beta,rc)を含んだバージョン
if [ -n "$PRE" ];then
    FULLVER=$NUMVER-$PRE
else
    FULLVER=$NUMVER
fi

#リリース日付
RELEASE_DATE=$(date "+%Y-%m-%d")

#バージョン番号ファイル(ビルドスクリプト用)
echo $FULLVER > $SCRIPT_DIR/VERSION 


#パッケージ設定ファイル
perl -pi -e "s/<Version>.*<\/Version>/<Version>$FULLVER<\/Version>/" $SCRIPT_DIR/skeleton/config/config.xml
perl -pi -e "s/<Version>.*<\/Version>/<Version>$FULLVER<\/Version>/" $SCRIPT_DIR/skeleton/packages/org.eithttails.programlistocr/meta/package.xml
perl -pi -e "s/<ReleaseDate>.*<\/ReleaseDate>/<ReleaseDate>$RELEASE_DATE<\/ReleaseDate>/" $SCRIPT_DIR/skeleton/packages/org.eithttails.programlistocr/meta/package.xml
