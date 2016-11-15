#!/bin/sh

#  RebuildInstaller.sh
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

if [[ "$CONFIGURATION" != Release* ]]; then
	exit "Can't build for Non-Deployment Style"
fi

export REAL_PRODUCT="$MAIN_PRODUCT_NAME"
export MY_SOURCE_INSTALLATION_DIR="$SRCROOT/$REAL_PRODUCT/Installation"
export MY_INSTALLER_FILE="Install $REAL_PRODUCT.mpinstall"
export MY_UNINSTALLER="Uninstall $REAL_PRODUCT"
export MY_UNINSTALLER_FILE="Uninstall $REAL_PRODUCT.mpremove"
export MY_RELEASE_FOLDER="$RELEASE_FOLDER"
export MY_PREP_DIR="$MY_RELEASE_FOLDER/$REAL_PRODUCT"
export MPM_PUBLIC_EXEC_FOLDER="$SRCROOT/../MPMPublic/Releases"
#export MPM_PUBLIC_EXEC_FOLDER="$HOME/Projects/Littleknown/MailPluginManager/MPMPublic/Releases"

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

# Move to the Resources Folder
cd "$MY_INSTALLER_APP/Contents/Resources"

# Delete installer files in the Resources folder
echo "Deleting any un/installer files in $MY_INSTALLER_APP/Contents/Resources"
rm -Rf *.mpinstall *.mpremove

# Copy stuff into the Delivery folder
cp -Rf "$MPM_PUBLIC_EXEC_FOLDER/Mail Plugin Manager.app" "."
mv -f "$MY_PREP_DIR/$MY_INSTALLER_FILE" "."

# If there is a Delivery Folder Path, the copy it's contents as well
if [[ "$DELIVERY_ITEMS_FOLDER" != "" ]]; then
	echo "Copying other delivery items…"
	cp -RfL "$DELIVERY_ITEMS_FOLDER/"* "./$MY_INSTALLER_FILE"
else
	echo "No other delivery items found"
fi

cd "$MY_PREP_DIR"

# Resign it
SetFile -a CBE "$MY_INSTALLER_APP"
# Ensure all Finder Attributes are cleared
xattr -cr "$MY_INSTALLER_APP"
codesign -s "Developer ID" --deep -f -v "$MY_INSTALLER_APP"

