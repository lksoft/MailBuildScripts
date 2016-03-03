#!/usr/bin/perl -w

#  PublishFilesToAWS.pl
#  BuildScripts
#
#  Created by Scott Little on 02/03/2016.
#  Copyright (c) 2016 Little Known Software. All rights reserved.

use strict;
use File::Basename;

my $dirName = dirname(__FILE__);

# If we are just testing the deploy process, do waste time pushing either
if ($ENV{"TESTING_DEPLOY"} ne "NO") {
	print "Skipping the Copying of files to AWS server for deploy porcess testing.\n";
	exit(0);
}

print "Copying files to AWS Server\n";
my $versionString = `cat "$ENV{"TEMP_VERSION_STRING_PATH"}"`;
my $uploaderPath = "$dirName/Upload2AWS.pl";
my $releaseFolder = $ENV{"RELEASE_FOLDER"};
my $productCode = $ENV{"PRODUCT_CODE"};
my $versionedProductName = $ENV{"MAIN_PRODUCT_NAME"}. ".$versionString";

print `"$uploaderPath" "$releaseFolder" "$versionedProductName.dmg" $productCode`;
print `"$uploaderPath" "$releaseFolder" "$versionedProductName.mpinstall.tar.bz2" $productCode "sparkle"`;

if ($ENV{"BUILD_TYPE"} eq "RELEASE") {
	print `"$uploaderPath" "$releaseFolder" "$versionedProductName.tar.bz2" $productCode "sparkle"`;
}

# Then find all the feed files and send those up to the server
my $tempFeedsFolder = $ENV{"TEMP_DIR"}. "/feeds";
my @fileList;
opendir(DIR, $tempFeedsFolder) or die "Couldn't open folder for $tempFeedsFolder: $!";
while (defined(my $aFile = readdir(DIR))) {
	if ($aFile =~ /\.xml$/i) {
		push (@fileList, $aFile);
	}
}
closedir(DIR);

foreach my $feedFile (@fileList) {
	print `"$uploaderPath" "$tempFeedsFolder" "$feedFile" $productCode "sparkle"`;
}
