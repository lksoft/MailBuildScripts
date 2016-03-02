#!/usr/bin/perl -w

#  PublishPost.pl
#  Tealeaves
#
#  Created by Scott Little on 9/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;
use warnings;
use feature qw(switch);
use JSON qw( decode_json );
use File::Basename;

my $dirname = dirname(__FILE__);
my $productCode;
my $productName;
my $versionString;

if ($ENV{"MAIN_PRODUCT_NAME"}) {
	$productName = $ENV{"MAIN_PRODUCT_NAME"};
	if ($ENV{"COMPACT_PRODUCT_NAME"}) {
		$productName = $ENV{"COMPACT_PRODUCT_NAME"};
	}
	$productCode = $ENV{"PRODUCT_CODE"};
	$versionString = `cat "$ENV{TEMP_VERSION_STRING_PATH}"`;
}
else {	#	For Command Line Testing purposes only!
	$productCode = $ARGV[0];
	$versionString = $ARGV[1];
	$productName = "Tealeaves";
	if ($productCode eq "sigpro") {
		$productName = "SignatureProfiler";
	}
	if ($productCode eq "mpm") {
		$productName = "MailPluginManager";
	}
}

#	Get the date
(my $mappedVersion = $versionString) =~ s/\./-/g;
my $postName = lc("$productName-$mappedVersion-released");
my $postContents = "";

#	Build the post contents
#	Look for any blog drafts
my $draftDir = "/Users/scott/Dropbox/PlainText/Blog Drafts/";
if (opendir(DIR, $draftDir)) {
	while (defined(my $aFile = readdir(DIR))) {
		if ($aFile =~ m/$postName/i) {
			$postContents = do {
				local $/ = undef;
				if (open my $fh, "<", ($draftDir . $aFile)) {
					<$fh>;
				}
			};
			if ((defined $postContents) && ($postContents ne "")) {
				unlink($draftDir . $aFile);
				last;
			}
		}
	}
	closedir(DIR);
}

my $sitePath = $ENV{"PRODUCT_SITE_PATH"};
#	If there is no blog draft, then load default content
if ($postContents eq "") {
	my $blogTemplatePath = "$sitePath/_includes/post/$productCode"."_auto.html";
	$postContents = do {
		local $/ = undef;
		open my $fh, "<", $blogTemplatePath
			or die "Could not open $blogTemplatePath for reading: $!";
		<$fh>;
	};
}

my $changeContents = "<p>Release Notes for this version:</p>";
$changeContents .= `"$dirname/ReleaseNotesAsHTML.pl" "$productCode" "$versionString" "$sitePath" "$ENV{SUPPLEMENTAL_VERSION_INFO_PATH}"`;

my $nowDate = `date "+%Y-%m-%d %H:%M:%S %Z"`;
$nowDate =~ s/^\s+|\s+$//g;

#	Do the replacement
$postContents =~ s/__VERSION_STRING__/$versionString/g;
$postContents =~ s/__NOW_DATE__/$nowDate/g;
$postContents =~ s/__RELEASE_NOTES_CONTENTS__/$changeContents/;

# Write the contents to the post file
$nowDate =~ s/^([0-9-]+) .+$/$1/;
my $postFilePath = "$sitePath/_posts/$nowDate-$postName.markdown";
do {
	open my $fh, ">", $postFilePath
		or die "Could not open file $postFilePath for output: $!";
	print $fh $postContents;
}

