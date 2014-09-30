#!/usr/bin/perl -w

#  SetBuildNumbers.pl
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

use strict;

die "$0: Must be run from Xcode" unless $ENV{"BUILT_PRODUCTS_DIR"};

# Get the current git branch and sha hash
# 	to use them to set the CFBundleVersion value
my $gitCommand = "/usr/local/bin/git";
my $BRANCH=`$gitCommand symbolic-ref --short -q HEAD`;
my $SHAHASH=`$gitCommand rev-parse --short HEAD`;
my $GIT_VERSION = `$gitCommand log --pretty=format:'' | wc -l | sed 's/[ \t]//g'`;
my $INFO = "$ENV{BUILT_PRODUCTS_DIR}/$ENV{INFOPLIST_PATH}";

my $baseDir = ".";
if ($ENV{"SRCROOT"}) {
	$baseDir = $ENV{"SRCROOT"};
}
my $NEW_VERSION = `cat "$ENV{TEMP_VERSION_STRING_PATH}"`;

# trim the ends
$BRANCH =~ s/\s+$//;
$SHAHASH =~ s/\s+$//;
$GIT_VERSION =~ s/^\s+//;
$GIT_VERSION =~ s/\s+$//;

die "$0: No git branch found" unless $BRANCH;

# Get the contents as an XML format
my $info = `plutil -convert xml1 -o - "$INFO"`;

# replace both the branch name and the hash value
$info =~ s/\[BRANCH\]/$BRANCH/;
$info =~ s/\[SHA-HASH\]/$SHAHASH/;
$info =~ s/\[GIT-BUILD-COUNT\]/$GIT_VERSION/;
$info =~ s/\[VERSION-WITH-BETA\]/$NEW_VERSION/;

# Rewrite the contents to the file
open(FH, ">$INFO") or die "$0: $INFO: $!";
print FH $info;
close(FH);

# Rest the contents of the file to the binary version
`plutil -convert binary1 "$INFO"`;
