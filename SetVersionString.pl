#!/usr/bin/perl -w

#  SetVersionString.pl
#  Tealeaves
#
#  Created by Scott Little on 20/08/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;

die "$0: Must be run from Xcode" unless $ENV{"BUILT_PRODUCTS_DIR"};

if (-e $ENV{TEMP_VERSION_STRING_PATH}) {
	my $deleted = `rm "$ENV{TEMP_VERSION_STRING_PATH}"`;
}

my $COMMITS_SINCE_LAST_TAG=`git log \`git rev-list --tags --abbrev=0 --max-count=1\`.. --pretty=format:'%h' | wc -l | sed 's/[ \t]//g'`;
my $NEW_VERSION = $ENV{"VERSION_STRING"};

print "Value of BETA is" . $ENV{"BETA"};

if (($ENV{"BETA"} eq "YES") && ($COMMITS_SINCE_LAST_TAG > 0)) {
	$NEW_VERSION .= "b$COMMITS_SINCE_LAST_TAG";
}
$NEW_VERSION =~ s/\s+$//;

open my $fileHandle, ">", "$ENV{TEMP_VERSION_STRING_PATH}" or die "touch $ENV{TEMP_VERSION_STRING_PATH}: $!\n"; 
	print $fileHandle "$NEW_VERSION";
close $fileHandle;

