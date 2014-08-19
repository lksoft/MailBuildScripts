#!/bin/sh

#  InstallPlugin.sh
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

# run script to copy the built bundle into the Install directory
#	but only if it is a development build

PUB_DIR="$HOME/Dropbox/MailBundles"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FULL_PRODUCT="$PRODUCT_NAME.$WRAPPER_EXTENSION"
SOURCE_PATH="$BUILT_PRODUCTS_DIR/$FULL_PRODUCT"

if [ ! -d "$SOURCE_PATH" ]; then
	echo "No plugin to install"
	exit 0
fi

echo 'Copying plugin to Public directories...'

# Make sure that the Shared folders are there
if [[ -d "$PUB_DIR" && ! -d "$HOME/Library/Mail/V2/IMAP-lksofttest@imap.gmail.com" ]]; then

	echo "Copying tar file to $PUB_DIR"

	cd "$BUILT_PRODUCTS_DIR"
	
	# delete any previous version
	rm -Rf "$PUB_DIR/$PRODUCT_NAME.tar"

	# copy the bundle
	tar -cf "$PUB_DIR/$PRODUCT_NAME.tar" "$FULL_PRODUCT"

fi

if [ "$CONFIGURATION" == Release* ]; then
	exit 0
fi

# Don't do anything unless SJL's test environment is running
if [ ! -d "$HOME/Library/Mail/V2/IMAP-lksofttest@imap.gmail.com" ]; then
	echo "Not running test environment, won't replace plugin"
	exit 0
fi

# don't do anyting if mail is running
MYVAR=`osascript "$SCRIPT_DIR/EnsureMailTest.scpt"`
if [ $MYVAR == "-1" ]; then
	echo "Mail is Running, won't replace plugin"
	exit 0
fi

echo 'Deleting any old copy of plugin...'
DEST_PATH="$HOME/Library/Mail/Bundles/$FULL_PRODUCT"

# delete any previous version
rm -Rf "$DEST_PATH"

echo 'Copying just built plugin...'

# copy the bundle
cp -Rf "$SOURCE_PATH" "$DEST_PATH"
