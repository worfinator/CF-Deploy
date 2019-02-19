#!/bin/bash

# Default Values
WEBPATH="/export/www/wwwroot"
GITDEPLOYPATH="githooks"
TODAY=$(date)
LOGFILE="$WEBPATH/$GITDEPLOYPATH/log/githook.log"

# Check for command line args
if test -z "$1"; then
    echo "$TODAY - FAIL!!! Missing argument" >> $LOGFILE
else 
    # Values
    MYPATH=$1

    cd "$MYPATH"

    git --exec-path="$MYPATH" fetch --all > /dev/null
    git --exec-path="$MYPATH" fetch --tags > /dev/null
    git --exec-path="$MYPATH" tag
fi