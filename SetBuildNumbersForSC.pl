#!/usr/bin/perl -w

#  SetBuildNumbersForSC.pl
#  Tealeaves
#
#  Created by Scott Little on 9/9/16.
#  Copyright (c) 2016 Little Known Software. All rights reserved.

use strict;
use JSON qw/encode_json/;
use URI::Escape;

die "$0: Must be run from Xcode" unless $ENV{"BUILT_PRODUCTS_DIR"};

# Get the current git branch and sha hash
# 	to use them to set the CFBundleVersion value
my $gitCommand = "/usr/local/bin/git";
my $branch=`$gitCommand symbolic-ref --short -q HEAD`;
my $commitH=`$gitCommand rev-parse --short HEAD`;
my $infoPlistPath = "$ENV{BUILT_PRODUCTS_DIR}/$ENV{INFOPLIST_PATH}";

my $baseDir = ".";
if ($ENV{"SRCROOT"}) {
	$baseDir = $ENV{"SRCROOT"};
}

# trim the ends
$branch =~ s/\s+$//;
$commitH =~ s/\s+$//;

my %buildInfo;
$buildInfo{'product_code'} = $ENV{"PRODUCT_CODE"};
$buildInfo{'branch'} = "$branch";
$buildInfo{'commit'} = "$commitH";
my $json_package = encode_json(\%buildInfo);
$json_package = uri_escape_utf8($json_package);
my $buildNumber=`curl -s -X "POST" "https://smallcubed.com/build/number" -H "Content-Type: application/json; charset=utf-8" -d "$json_package"`;
$buildNumber =~ s/^\s+//;
$buildNumber =~ s/\s+$//;

# If we didn't get a build number then use the last one
my $buildNumberPath = "$ENV{SRCROOT}/buildNumber.txt";
if ("$buildNumber" eq "") {
	$buildNumber = `cat "$buildNumberPath"`;
}
else {
	if (-e "$buildNumberPath") {
		my $deleted = `rm "$buildNumberPath"`;
	}
	open my $fileHandle, ">", "$buildNumberPath" or die "touch $buildNumberPath: $!\n"; 
		print $fileHandle "$buildNumber";
	close $fileHandle;
}

if (!$branch) {
	$branch = 'DETACHED_HEAD';
}

die "$0: No git branch found" unless $branch;

# Get the contents as an XML format
my $info = `plutil -convert xml1 -o - "$infoPlistPath"`;

# replace both the branch name and the hash value
$info =~ s/\[BRANCH\]/$branch/;
$info =~ s/\[SHA-HASH\]/$commitH/;
$info =~ s/\[VERSION-WITH-BUILD\]/$ENV{"VERSION_STRING"}b$buildNumber/;
$info =~ s/\[VERSION-NUMBER\]/$ENV{"VERSION_STRING"}/;

# Rewrite the contents to the file
open(FH, ">$infoPlistPath") or die "$0: $infoPlistPath: $!";
print FH $info;
close(FH);

# Rest the contents of the file to the binary version
`plutil -convert binary1 "$infoPlistPath"`;





