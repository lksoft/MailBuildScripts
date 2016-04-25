#!/bin/sh

#  MakeInstallerPackage.sh
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
export MY_MPINSTALLER_FILE="$REAL_PRODUCT.mpinstall"
#export MY_UNINSTALLER="Uninstall $REAL_PRODUCT"
#export MY_UNINSTALLER_FILE="Uninstall $REAL_PRODUCT.mpremove"
export MY_RELEASE_FOLDER="$RELEASE_FOLDER"
export MY_PREP_DIR="$MY_RELEASE_FOLDER/$REAL_PRODUCT"

# Ensure that the installation directory exists, if not use without the REAL_PRODUCT name
if [[ ! -e $MY_SOURCE_INSTALLATION_DIR ]]; then
	export MY_SOURCE_INSTALLATION_DIR="$SRCROOT/Installation"
fi

echo "Installer dir=$MY_PREP_DIR"

#	ensure that we have a release folder
if [ ! -d "$MY_PREP_DIR" ]; then
	mkdir "$MY_PREP_DIR"
fi

# Go to the prep folder in the release folder
cd "$MY_PREP_DIR"

echo "Cleaning previous temp build files"
#	first delete old contents
rm -Rf *

#	copy in the installer and the readme
echo "Creating installation files"

#	make the installer file and copy in it's contents
#
#	first create the installer bundle folder
#	next, copy the files into it

mkdir "$MY_INSTALLER_FILE"

cp -R "$BUILT_PRODUCTS_DIR/$REAL_PRODUCT.mailbundle" "$MY_INSTALLER_FILE"
cp "$MY_SOURCE_INSTALLATION_DIR/install-manifest.plist" "$MY_INSTALLER_FILE/mpm-manifest.plist"
cp "$MY_SOURCE_INSTALLATION_DIR/ReleaseNotes.html" "$MY_INSTALLER_FILE"
cp "$MY_SOURCE_INSTALLATION_DIR/background-image.png" "$MY_INSTALLER_FILE/background-image.png"

echo "Setting installer Icon and flags"

#   then set the icon for the installer and hide the extension
SetFile -a C "$MY_INSTALLER_FILE"
/usr/local/bin/seticon -d "$MY_SOURCE_INSTALLATION_DIR/installer.icns" "$MY_INSTALLER_FILE"
SetFile -a BE "$MY_INSTALLER_FILE"


#	make the mpinstall package for in app updates
echo "Creating mpinstall package"

#	make the installer file and copy in it's contents
#
#	first create the installer bundle folder
#	next, copy the files into it

mkdir "$MY_MPINSTALLER_FILE"

cp "$MY_SOURCE_INSTALLATION_DIR/in-app-install-manifest.plist" "$MY_MPINSTALLER_FILE/mpm-manifest.plist"
cp -R "$BUILT_PRODUCTS_DIR/$REAL_PRODUCT.mailbundle" "$MY_MPINSTALLER_FILE"
# If there is a Delivery Folder Path, the copy it's contents as well
if [[ "$DELIVERY_ITEMS_FOLDER" != "" ]]; then
	echo "Copying other delivery items…"
	cp -RfL "$DELIVERY_ITEMS_FOLDER/"* "./$MY_MPINSTALLER_FILE"
else
	echo "No other delivery items found"
fi

echo "Setting installer Icon and flags"

#   then set the icon for the installer and hide the extension
SetFile -a C "$MY_MPINSTALLER_FILE"
#/usr/local/bin/seticon -d "$MY_SOURCE_INSTALLATION_DIR/installer.icns" "$MY_MPINSTALLER_FILE"
SetFile -a BE "$MY_MPINSTALLER_FILE"




######


#	copy in the uninstaller and the readme
#echo "Creating uninstallation files"

#	make the installer file and copy in it's contents
#
#	first create the installer bundle folder
#	next, copy the files into it

#mkdir "$MY_UNINSTALLER_FILE"

#cp "$MY_SOURCE_INSTALLATION_DIR/uninstall-manifest.plist" "$MY_UNINSTALLER_FILE/mpm-manifest.plist"
#cp "$MY_SOURCE_INSTALLATION_DIR/RemovalNotes.html" "$MY_UNINSTALLER_FILE"
#cp "$MY_SOURCE_INSTALLATION_DIR/background-image.png" "$MY_UNINSTALLER_FILE/background-image.png"

#echo "Setting installer Icon and flags"

#   then set the icon for the installer and hide the extension
#SetFile -a C "$MY_UNINSTALLER_FILE"
#/usr/local/bin/seticon -d "$MY_SOURCE_INSTALLATION_DIR/uninstaller.icns" "$MY_UNINSTALLER_FILE"
#SetFile -a BE "$MY_UNINSTALLER_FILE"
