#!/bin/bash

PLUGIN_NAME="cuhk-library"
VERSION="v2.5.3"

ASPACE_ROOT="/d/bin/archivesspace"
PLUGIN_DIR="$ASPACE_ROOT/plugins"

trap ctrl_c INT
function ctrl_c() {
    exit
}

echo "Deploying..."
mkdir -p deployables
if [ ! -z "$1" ]
then
    OUTFILE_NAME="$PLUGIN_NAME-$VERSION-$1.zip"
    if [[ "$1" == "prod" ]]
    then
        OUTFILE_NAME="$PLUGIN_NAME-$VERSION.zip"
    fi
    tar czf deployables/$OUTFILE_NAME --exclude "deployables" --exclude ".git*" --exclude "make.sh" *
    rm -rf $PLUGIN_DIR/$PLUGIN_NAME
    mkdir $PLUGIN_DIR/$PLUGIN_NAME
    tar xzf deployables/$OUTFILE_NAME --directory $PLUGIN_DIR/$PLUGIN_NAME
fi

echo "Starting server..."
$ASPACE_ROOT/archivesspace-dev.bat
