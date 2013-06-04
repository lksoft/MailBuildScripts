#!/bin/sh

#  ConstructRelease.sh
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

# shell script goes here
if [ $CONFIGURATION != "Release" ]; then
	exit "Can't build for Non-Deployment Style"
fi

export REAL_PRODUCT="$MAIN_PRODUCT_NAME"
export MY_SOURCE_INSTALLATION_DIR="$SRCROOT/$REAL_PRODUCT/Installation"
export MY_RELEASE_FOLDER="$SRCROOT/../Releases"
export MY_PRODUCT_NEW_NAME="$REAL_PRODUCT.New"
export MY_PRODUCT_VERSIONED_NAME="$REAL_PRODUCT.$VERSION_STRING"

echo "Creating the zip file for Sparkle"

cd "$BUILT_PRODUCTS_DIR"

#   remove old zip file if it exists
if [ -f "$MY_RELEASE_FOLDER/$MY_PRODUCT_NEW_NAME.tar.bz2" ]; then
	rm -f "$MY_RELEASE_FOLDER/$MY_PRODUCT_NEW_NAME.tar.bz2"
fi

#   if there is already a versioned file existing, use the New value
if [ -f "$MY_RELEASE_FOLDER/$MY_PRODUCT_VERSIONED_NAME.tar.bz2" ]; then
	export MY_VERSIONED_NAME="$MY_PRODUCT_NEW_NAME"
else
	export MY_VERSIONED_NAME="$MY_PRODUCT_VERSIONED_NAME"
fi

#   zip the file into versioned name
if [[ "$OLD_PRODUCT_NAME" == "" ]]; then
	tar -cyf "$MY_RELEASE_FOLDER/$MY_VERSIONED_NAME.tar.bz2" "$REAL_PRODUCT.mailbundle"
else
#	if there is an old product name package the two together in the zip file and Sparkle will use the right one
	cp -R "$REAL_PRODUCT.mailbundle" "$OLD_PRODUCT_NAME.mailbundle"
	tar -cyf "$MY_RELEASE_FOLDER/$MY_VERSIONED_NAME.tar.bz2" "$REAL_PRODUCT.mailbundle" "$OLD_PRODUCT_NAME.mailbundle"
	rm -Rf "$OLD_PRODUCT_NAME.mailbundle"
fi

echo "Building Disk Image"

cd "$MY_RELEASE_FOLDER"

#   remove old images if they exist
if [ -f "$REAL_PRODUCT.dmg" ]; then
	rm -f "$REAL_PRODUCT.dmg"
fi
if [ -f "$MY_PRODUCT_NEW_NAME.dmg" ]; then
	rm -f "$MY_PRODUCT_NEW_NAME.dmg"
fi

#   if there is already a versioned file existing, use the New value
if [ -f "$MY_PRODUCT_VERSIONED_NAME.dmg" ]; then
	export MY_VERSIONED_NAME="$MY_PRODUCT_NEW_NAME"
else
	export MY_VERSIONED_NAME="$MY_PRODUCT_VERSIONED_NAME"
fi

#   build the image file
echo "layout folder: $MY_SOURCE_INSTALLATION_DIR/$REAL_PRODUCT"
dropdmg --layout-folder="$MY_SOURCE_INSTALLATION_DIR/$REAL_PRODUCT" --volume-name="$REAL_PRODUCT" "$MY_RELEASE_FOLDER/$REAL_PRODUCT"
mv "$REAL_PRODUCT.dmg" "$MY_VERSIONED_NAME.dmg"

exit 0