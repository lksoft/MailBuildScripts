#!/usr/bin/perl -w

#  PublishFilesToAWS.pl
#  BuildScripts
#
#  Created by Scott Little on 02/03/2016.
#  Copyright (c) 2016 Little Known Software. All rights reserved.

use strict;
use File::Basename;

my $dir_name = dirname(__FILE__);

# If we are just testing the deploy process, do waste time pushing either
if ($ENV{"TESTING_DEPLOY"} ne "NO") {
	print "Skipping the Copying of files to AWS server for deploy porcess testing.\n";
	exit(0);
}

print "Copying files to AWS Server\n";
my $version_string = `cat "$ENV{"TEMP_VERSION_STRING_PATH"}"`;
my $uploader_path = "$dir_name/Upload2AWS.pl";
my $release_folder = $ENV{"RELEASE_FOLDER"};
my $product_code = $ENV{"PRODUCT_CODE"};
my $versioned_product_name = $ENV{"MAIN_PRODUCT_NAME"}. ".$version_string";
if ($ENV{"COMPACT_PRODUCT_NAME"}) {
	$versioned_product_name = $ENV{"COMPACT_PRODUCT_NAME"}. ".$version_string";
}

print `"$uploader_path" "$release_folder" "$versioned_product_name.dmg" $product_code`;
if ("$product_code" ne "mpm") {
	print `"$uploader_path" "$release_folder" "$versioned_product_name.mpinstall.tar.bz2" $product_code "sparkle"`;
}

if (($ENV{"BUILD_TYPE"} eq "RELEASE") || ("$product_code" eq "mpm")) {
	print `"$uploader_path" "$release_folder" "$versioned_product_name.tar.bz2" $product_code "sparkle"`;
}

# Then find all the feed files and send those up to the server
my $temp_feeds_folder = $ENV{"TEMP_FEEDS_FOLDER"};
my @file_list;
opendir(DIR, $temp_feeds_folder) or die "Couldn't open folder for $temp_feeds_folder: $!";
while (defined(my $a_file = readdir(DIR))) {
	if ($a_file =~ /\.xml$/i) {
		push (@file_list, $a_file);
	}
}
closedir(DIR);

foreach my $feed_file (@file_list) {
	print `"$uploader_path" "$temp_feeds_folder" "$feed_file" $product_code "sparkle"`;
}
