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
my $GIT_INFO = `git --work-tree="$ENV{PROJECT_DIR}" branch --abbrev=10 -v | grep '^*'`;
my $BRANCH = $GIT_INFO;
my $SHAHASH = $GIT_INFO;
my $GIT_VERSION = `git log --pretty=format:'' | wc -l | sed 's/[ \t]//g'`;
my $INFO = "$ENV{BUILT_PRODUCTS_DIR}/$ENV{INFOPLIST_PATH}";

# Extract the branch and sha
$BRANCH =~ s/^\*\s([^\s]+)(\s+)[^\$]*/$1/;
$SHAHASH =~ s/^\*\s([^\s]+)(\s+)([0-9a-f]+)[^\$]*/$3/;

# trim the ends
$BRANCH =~ s/^\s+//;
$BRANCH =~ s/\s+$//;
$SHAHASH =~ s/^\s+//;
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

# Rewrite the contents to the file
open(FH, ">$INFO") or die "$0: $INFO: $!";
print FH $info;
close(FH);

# Rest the contents of the file to the binary version
`plutil -convert binary1 "$INFO"`;
