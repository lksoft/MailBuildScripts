#!/bin/sh

#  InstallSCPlugin.sh
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

# run script to copy the built bundle into the Install directory
#	but only if it is a development build

SCRIPT_DIR=$( dirname "${BASH_SOURCE[0]}" )

FULL_PRODUCT="$PRODUCT_NAME.$WRAPPER_EXTENSION"
SOURCE_PATH="$BUILT_PRODUCTS_DIR/$FULL_PRODUCT"

if [ ! -d "$SOURCE_PATH" ]; then
	echo "No plugin to install"
	exit 0
fi

if [ "$CONFIGURATION" == Release* ]; then
	exit 0
fi

DEST_FOLDER="$HOME/Library/Mail/SmallCubed/Components"

if [ ! -d "$DEST_FOLDER" ]; then
	echo "Creating Bundle Folder: ${DEST_FOLDER}"
	mkdir "$DEST_FOLDER"
fi

echo 'Deleting any old copy of plugin...'
DEST_PATH="$DEST_FOLDER/$FULL_PRODUCT"

# delete any previous version
rm -Rf "$DEST_PATH"

echo 'Copying just built plugin...'

# copy the bundle
cp -Rf "$SOURCE_PATH" "$DEST_PATH"
