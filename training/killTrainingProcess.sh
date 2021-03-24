#!/bin/bash

if [ "$MINGW_CHOST" != "" ]; then
    function killWinProcess()
    {
        toolname=$1
        ps -W|grep $toolname | tr -s ' ' | cut -f5 -d ' '| xargs -l1 powershell kill -f 2> /dev/null
    }

    killWinProcess text2image
    killWinProcess tesseract
    killWinProcess lstmtraining
else
    echo "#TODO not implemented"
fi
