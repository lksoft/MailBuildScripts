#!/usr/bin/perl -w

#  PublishPost.pl
#  Tealeaves
#
#  Created by Scott Little on 9/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;
use warnings;
use JSON qw( decode_json );

my $productCode;
my $productName;
my $versionString;
my $postPath = "";
my $shouldRetweet = 0;
my $argParseStart = 0;

if ($ENV{"MAIN_PRODUCT_NAME"}) {
	$productName = $ENV{"MAIN_PRODUCT_NAME"};
	if ($ENV{"COMPACT_PRODUCT_NAME"}) {
		$productName = $ENV{"COMPACT_PRODUCT_NAME"};
	}
	$productCode = $ENV{"PRODUCT_CODE"};
	$versionString = $ENV{"VERSION_STRING"};
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
	$argParseStart = 2;
}

#	Get passed in variables
my $argCount = scalar @ARGV;
if ($argCount > $argParseStart) {
	if ($ARGV[$argParseStart] =~ m/^(yes|no)$/i) {
		if (lc($ARGV[$argParseStart]) eq "yes") {
			$shouldRetweet = 1;
		}
		$argParseStart++;
	}
	if ($argCount > $argParseStart) {
		$postPath = $ARGV[$argParseStart];
	}
}

#	Build the post contents
my $postContents = "";

#	Look for any blog drafts
my $draftDir = "/Users/scott/Dropbox/PlainText/Blog Drafts/";
(my $mappedVersion = $versionString) =~ s/\./-/g;
if (opendir(DIR, $draftDir)) {
	while (defined(my $aFile = readdir(DIR))) {
		if ($aFile =~ m/$productName-$mappedVersion-released/i) {
			$postContents = do {
				local $/ = undef;
				open my $fh, "<", $aFile
					or die "Could not open $aFile for reading: $!";
				<$fh>;
			};
			unlink($aFile);
			break;
		}
	}
	closedir(DIR);
}

my $sitePath = "/Users/scott/Sites/lksite/";
#	If we need to make a new post
if ($postContents eq "") {
	$postContents = "--- 
layout: post
title: \"$productName $versionString released.\"
date: $nowDate
categories: [$productName, Release]
---
We have just released a new version of <span class=\"product-name\">$productName</span> (version $versionString).

For more information, visit the [site](/$productCode) or [download](/download/$productCode) it directly.
";

	my $versionJSON;
	my $JSONFileDIR = $sitePath . "/source/services/config/version-info/" . $productCode;
	# . "/" . $buildNumber . "-" . $versionString . ".json";
	if (opendir(DIR, $JSONFileDIR)) {
		while (defined(my $aFile = readdir(DIR))) {
			if ($aFile =~ m/$versionString\.json$/i) {
				$versionJSON = do {
					local $/ = undef;
					open my $fh, "<", $aFile
						or die "Could not open $aFile for reading: $!";
					<$fh>;
				};
				break;
			}
		}
		closedir(DIR);
	}
	
	if (defined $versionJSON) {
		my $decoded = decode_json($versionJSON);
		my @changeList = @{ $decoded->{"lang"}{"en"}{"changes"} };
		foreach my $change (@changeList) {
		}
	}
}




#	Ensure that we really have an authorization for this account
my $accountInfo = `cd $sitePath;twurl accounts`;
if ($accountInfo !~ m/$accountName/) {
	print "Account ‘$accountName’ not found in twurl or twurl not installed.\n";
	exit 1;
}

