#!/bin/bash

PLUGIN_NAME="cuhk-library"
VERSION="v2.0.0"

ASPACE_ROOT="/d/bin/archivesspace"
PLUGIN_DIR="$ASPACE_ROOT/plugins"

trap ctrl_c INT
function ctrl_c() {
    exit
}

echo "Deploying..."
mkdir -p deployables
if [[ "$1" == "dev" ]]
then
    OUTFILE_NAME="$PLUGIN_NAME-$VERSION-dev.zip"
    DEV_STASH_NAME=`git stash create`
    echo $DEV_STASH_NAME
    git archive $DEV_STASH_NAME -o deployables/$OUTFILE_NAME
else
    OUTFILE_NAME="$PLUGIN_NAME-$VERSION.zip"
    git archive HEAD -o deployables/$OUTFILE_NAME
fi
rm -rf $PLUGIN_DIR/$PLUGIN_NAME
mkdir $PLUGIN_DIR/$PLUGIN_NAME
unzip deployables/$OUTFILE_NAME -d $PLUGIN_DIR/$PLUGIN_NAME

echo "Starting server..."
$ASPACE_ROOT/archivesspace-dev.bat
