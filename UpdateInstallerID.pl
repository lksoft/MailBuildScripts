#!/usr/bin/perl -w

#  UpdateInstallerID.pl
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.


use strict;

die "$0: Must be run from Xcode" unless $ENV{"BUILT_PRODUCTS_DIR"};

# Get the current git branch and sha hash
# 	to use them to set the CFBundleVersion value
my $NEW_ID = "$ENV{INSTALLER_SUB_ID}";
print "New ID:$NEW_ID\n";
my $INFO_FILE = "$ENV{BUILT_PRODUCTS_DIR}/Plugin Installer.app/Contents/Info.plist";
print "Info File:$INFO_FILE\n";

# Get the contents as an XML format
my $info = `plutil -convert xml1 -o - "$INFO_FILE"`;

# replace both the branch name and the hash value
$info =~ s/REPLACESUBID/$NEW_ID/g;

# Rewrite the contents to the file
open(FH, ">$INFO_FILE") or die "$0: $INFO_FILE: $!";
print FH $info;
close(FH);

# Rest the contents of the file to the binary version
`plutil -convert binary1 "$INFO_FILE"`;

# Also rename the actual helper file inside the Installer
my $HELPER_BASE = "com.littleknownsoftware.MPC.CopyMoveHelper";
my $HELPER_FOLDER = "$ENV{BUILT_PRODUCTS_DIR}/Plugin Installer.app/Contents/Library/LaunchServices";
`mv "$HELPER_FOLDER/$HELPER_BASE" "$HELPER_FOLDER/$HELPER_BASE.$NEW_ID"`;
