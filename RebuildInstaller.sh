#!/bin/sh

#  RebuildInstaller.sh
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

if [ $CONFIGURATION != "Release" ]; then
	exit "Can't build for Non-Deployment Style"
fi

export REAL_PRODUCT="$MAIN_PRODUCT_NAME"
export MY_SOURCE_INSTALLATION_DIR="$SRCROOT/$REAL_PRODUCT/Installation"
export MY_INSTALLER_FILE="Install $REAL_PRODUCT.mpinstall"
export MY_UNINSTALLER="Uninstall $REAL_PRODUCT"
export MY_UNINSTALLER_FILE="Uninstall $REAL_PRODUCT.mpremove"
export MY_RELEASE_FOLDER="$SRCROOT/../Releases"
export MY_PREP_DIR="$MY_RELEASE_FOLDER/$REAL_PRODUCT"
export MPM_PUBLIC_EXEC_FOLDER="$SRCROOT/../MPMPublic/Releases"

# Ensure that the installation directory exists, if not use without the REAL_PRODUCT name
if [[ ! -e $MY_SOURCE_INSTALLATION_DIR ]]; then
	export MY_SOURCE_INSTALLATION_DIR="$SRCROOT/Installation"
fi

export MY_INSTALLER_APP="Open to Install $REAL_PRODUCT.app"

# First go to the prep folder
cd "$MY_PREP_DIR"

# Copy the Installer with a new name
cp -R "$MPM_PUBLIC_EXEC_FOLDER/Plugin Installer.app" "$MY_INSTALLER_APP"

# Copy the Icons in
cp "$BUILT_PRODUCTS_DIR/$REAL_PRODUCT.mailbundle/Contents/Resources/$REAL_PRODUCT.icns" "$MY_INSTALLER_APP/Contents/Resources/ManagerIcons.icns"

# Set the proper Bundle ID for the installer
export INFO_FILE="$MY_INSTALLER_APP/Contents/Info.plist"

# Convert the plist to a temp xml file
plutil -convert xml1 -o "temp.plist" "$INFO_FILE"

# Replace the subid & delete first version
sed -e "s/REPLACESUBID/$INSTALLER_SUB_ID/g" temp.plist > temp2.plist
rm temp.plist
# Replace the installer name & delete second version
sed -e "s/INSTALLERBUNDLENAME/$INSTALLER_BUNDLE_NAME/g" temp2.plist > temp.plist
rm temp2.plist

# Rewrite the contents of the file to the binary version
plutil -convert binary1 -o "$INFO_FILE" temp.plist
rm temp.plist

# Move to the Delivery Folder
cd "$MY_INSTALLER_APP/Delivery"

# Delete anything in the Delivery folder
echo "Deleting anything in $MY_INSTALLER_APP/Delivery"
rm -Rf *

# Copy stuff into the Delivery folder
cp -Rf "$MPM_PUBLIC_EXEC_FOLDER/Mail Plugin Manager.app" "."
mv -f "$MY_PREP_DIR/$MY_INSTALLER_FILE" "."

# Resign it
cd "$MY_PREP_DIR"
codesign -f -s "Developer ID" -v "$MY_INSTALLER_APP"
