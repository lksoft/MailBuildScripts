#!/bin/sh

#  InstallPlugin.sh
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

# run script to copy the built bundle into the Install directory
#	but only if it is a development build

echo 'Action is: '$ACTION

echo 'Copying plugin to Public directory...'

PUB_DIR="$HOME/Dropbox/MailBundles"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Make sure that the Dropbox folder is there
if [ -d $PUB_DIR ]; then

	# delete any previous version
	rm -Rf "$PUB_DIR/$PRODUCT_NAME.$WRAPPER_EXTENSION"

	# copy the bundle
	cp -Rf "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.$WRAPPER_EXTENSION" "$PUB_DIR"

fi


if [ $CONFIGURATION == "Release" ]; then
	exit 0
fi

# don't do anyting if mail is running
MYVAR=`osascript "$SCRIPT_DIR/EnsureMailTest.scpt"`
if [ $MYVAR == "-1" ]; then
	echo "Mail is Running, won't replace plugin"
	exit 0
fi

echo 'Deleting any old copy of plugin...'

# delete any previous version
rm -Rf "$INSTALL_PATH/$PRODUCT_NAME.$WRAPPER_EXTENSION"

echo 'Copying just built plugin...'

# copy the bundle
cp -Rf "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.$WRAPPER_EXTENSION" "$INSTALL_PATH"
