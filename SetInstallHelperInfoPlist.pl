#!/usr/bin/perl -w

use strict;

die "$0: Must be run from Xcode" unless $ENV{"BUILT_PRODUCTS_DIR"};

# Ensure that the proper values have been setup
die "No installation sub id found for project [INSTALLER_SUB_ID]" unless $ENV{"INSTALLER_SUB_ID"};
die "No Codesign identity found" unless $ENV{"CODE_SIGN_IDENTITY"};
die "The Root Helper folder was not found [COPY_MOVE_DIR]" unless $ENV{"COPY_MOVE_DIR"};

# Get the current git branch and sha hash
# 	to use them to set the CFBundleVersion value
my $INFO_SOURCE = "$ENV{COPY_MOVE_DIR}/CopyMoveHelper-Info.plist";
my $INFO_DEST = "$ENV{COPY_MOVE_DIR}/CopyMoveHelperFixed-Info.plist";

# Get the contents as an XML format
my $info = `plutil -convert xml1 -o - "$INFO_SOURCE"`;

# replace both the branch name and the hash value
$info =~ s/REPLACESUBID/$ENV{"INSTALLER_SUB_ID"}/;
$info =~ s/CODESIGNID/$ENV{"CODE_SIGN_IDENTITY"}/;

# Rewrite the contents to the file
open(FH, ">$INFO_DEST") or die "$0: $INFO_DEST: $!";
print FH $info;
close(FH);

