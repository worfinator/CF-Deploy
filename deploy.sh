#!/bin/bash

# Mark's magic script to deploy via web hook
# Make sure that you 
# chmod +x deploy.sh
# so you can run this script
# Check the log file for any problems
# or run from the command line with 
# the appropriate arguments
# e.g. ./deploy.sh 

# ARGUMENTS
# $1=environment $2=path $3=repo $4=branch $5=tag


# Default Values
HOST=myserver.com
WEBPATH="/export/www/wwwroot"
GITDEPLOYPATH="githooks"
LOGFILE="$WEBPATH/$GITDEPLOYPATH/log/githook.log"
TODAY=$(date)

# Check for command line args
if test -z "$1" || test -z "$2" || test -z "$3" || test -z "$4"; then
    echo "$TODAY - FAIL!!! Missing arguments" >> $LOGFILE
else 
    # Values
    ENVIRONMENT=$1
    MYPATH=$2
    REPO=$3
    BRANCH=$4
    TAG=$5

    MYDIR="${REPO/-/_}"

    CDPATH="$WEBPATH/$MYPATH/$MYDIR/"

    echo "$TODAY - Deploying $REPO codebase to $ENVIRONMENT" >> $LOGFILE

    echo "deploy.sh $ENVIRONMENT $MYPATH $REPO $BRANCH $TAG" >> $LOGFILE

    # Change into directory
    echo "Changing into $CDPATH directory" >> $LOGFILE
    cd "$CDPATH"

    # Update repo
    echo "Running git fetch on $ENVIRONMENT $REPO" >> $LOGFILE
    git fetch --all >> $LOGFILE
    git fetch --tags >> $LOGFILE
    git clean -f >> $LOGFILE
    
    # Checkout branch or tag
    if test -z "$5"; then
        echo "Checking out $ENVIRONMENT $REPO to latest commit on $BRANCH branch" >> $LOGFILE
        git checkout -f "$BRANCH" >> $LOGFILE       
    else
        echo "Checking out $ENVIRONMENT $REPO to latest tag $TAG on $BRANCH branch" >> $LOGFILE
        git checkout -f "$TAG" >> $LOGFILE
    fi
    $CHECKOUT
    
    # Pull and update submodule
    echo "Running git pull and submodule update on $ENVIRONMENT $REPO" >> $LOGFILE
    git pull >> $LOGFILE
    git submodule update >> $LOGFILE

    # Call CF Page to send email
    echo "Sending Deployment Email" >> $LOGFILE
    EMAILURL="http://$HOST/notification.cfm?e=$ENVIRONMENT&r=$REPO&b=$BRANCH&t=$TAG&p=$MYPATH"
    curl $EMAILURL
fi