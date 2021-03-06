#!/bin/sh

#  InstallPlugin.sh
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

echo 'Copying plugin to Public directories...'

if [ "$CONFIGURATION" == Release* ]; then
	exit 0
fi

DEST_FOLDER="$HOME/Library/Mail/Bundles"

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


# see if we can install in DataVault
VAULT_FOLDER="${HOME}/Library/Containers/com.apple.mail/Data/DataVaults/MailBundles${DEST_FOLDER}"
DEST_PATH="${VAULT_FOLDER}/${FULL_PRODUCT}"

echo "Testing for DataVault folder at ${VAULT_FOLDER}"

if [ -d "${VAULT_FOLDER}" ]; then

	echo 'Deleting DataVault copy of plugin...'

	# delete any previous version
	rm -Rf "${DEST_PATH}"

	echo 'Copying just built plugin into Vault...'

	# copy the bundle
	cp -Rf "${SOURCE_PATH}" "${DEST_PATH}"

fi