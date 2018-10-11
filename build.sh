#!/bin/bash

PLUGIN_DIR="/d/bin/archivesspace/plugins"
PLUGIN_NAME="cuhk-library-theme"
VERSION="v2.0.0"

OUTFILE_NAME="$PLUGIN_NAME-$VERSION.zip"

git archive HEAD -o deployables/$OUTFILE_NAME
rm -rf $PLUGIN_DIR/$PLUGIN_NAME
mkdir $PLUGIN_DIR/$PLUGIN_NAME
unzip deployables/$OUTFILE_NAME -d $PLUGIN_DIR/$PLUGIN_NAME
