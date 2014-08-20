#!/bin/sh

#  MakeSparkleFile.sh
#  Mail Plugin Manager
#
#  Created by Scott Little on 10/7/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

if [ $CONFIGURATION != "Release" ]; then
	echo "Not packaging for Non-Deployment Style"
fi

export REAL_PRODUCT="$MAIN_PRODUCT_NAME"
if [[ "$COMPACT_PRODUCT_NAME" == "" ]]; then
	export COMPACT_PRODUCT="$MAIN_PRODUCT_NAME"
else
	export COMPACT_PRODUCT="$COMPACT_PRODUCT_NAME"
fi
export VERSION=`cat $TEMP_VERSION_STRING_PATH`
export MY_RELEASE_FOLDER="$SRCROOT/../Releases"
export MY_PRODUCT_NEW_NAME="$COMPACT_PRODUCT.New"
export MY_PRODUCT_VERSIONED_NAME="$COMPACT_PRODUCT.$VERSION"

echo "Creating the zip file for Sparkle"

cd "$BUILT_PRODUCTS_DIR"

pwd

#   remove old zip file if it exists
if [ -f "$MY_RELEASE_FOLDER/$MY_PRODUCT_NEW_NAME.tar.bz2" ]; then
	rm -f "$MY_RELEASE_FOLDER/$MY_PRODUCT_NEW_NAME.tar.bz2"
fi

#   if the versioned name already exists, use the 'New' name
if [ -f "$MY_RELEASE_FOLDER/$MY_PRODUCT_VERSIONED_NAME.tar.bz2" ]; then
	export MY_PRODUCT_VERSIONED_NAME="$MY_PRODUCT_NEW_NAME"
fi

echo "Tarring and zipping File"

#   zip the file into new location
tar -cyf "$MY_RELEASE_FOLDER/$MY_PRODUCT_VERSIONED_NAME.tar.bz2" "$REAL_PRODUCT.app"

