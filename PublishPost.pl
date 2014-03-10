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

my $productCode;
my $productName;
my $versionString;

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
}

#	Get the date
my $nowDate = `date "+%Y-%m-%d %H:%M:%S"`;
$nowDate =~ s/^\s+|\s+$//g;
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
			}
		}
	}
	closedir(DIR);
}

my $sitePath = "/Users/scott/Sites/lksite/";
#	If there is no blog draft, then load default content
if ($postContents eq "") {
	my $blogTemplatePath = $sitePath . "source/_includes/post/" . $productCode . "_auto.html";
	$postContents = do {
		local $/ = undef;
		open my $fh, "<", $blogTemplatePath
			or die "Could not open $blogTemplatePath for reading: $!";
		<$fh>;
	};
}

#	Get the release notes into a replacing format
my $versionJSON;
my $JSONFileDIR = $sitePath . "/source/services/config/version-info/" . $productCode;
if (opendir(DIR, $JSONFileDIR)) {
	while (defined(my $aFile = readdir(DIR))) {
		if ($aFile =~ m/$versionString\.json$/i) {
			$versionJSON = do {
				local $/ = undef;
				open my $fh, "<", ($JSONFileDIR . "/" . $aFile)
					or die "Could not open $aFile for reading: $!";
				<$fh>;
			};
		}
	}
	closedir(DIR);
}
my $changeContents = "";
if (defined $versionJSON) {
	$versionJSON =~ s/^\s+|,\s+$//g;
	my $decoded = decode_json($versionJSON);
	my @changeList = @{ $decoded->{"lang"}{"en"}{"changes"} };
	
	#	Change Mappings
	my %changeMappings = (
		"new" => "New",
		"fix" => "Fixed",
		"os" => "OS Support",
		"internal" => "Maintenance"
	);
	
	# Reverse sort file list
	my @orderedChangeList = sort {
		my $aTest = 0;
		my $bTest = 0;
		given ($a) {
			when (/new/) { $aTest = 1 }
			when (/fix/) { $aTest = 2 }
			when (/os/) { $aTest = 3 }
			default { $aTest = 4 }
		}
		given ($b) {
			when (/new/) { $bTest = 1 }
			when (/fix/) { $bTest = 2 }
			when (/os/) { $bTest = 3 }
			default { $bTest = 4 }
		}
		$aTest cmp $bTest;
	} @changeList;
	# Get the contents of the changes into a variable
	$changeContents = "<p>Release Notes for this version:</p><ul class=\"new-features\">";
	foreach my $aChange (@orderedChangeList) {
		$changeContents .= "<li><span class=\"change-type $aChange->{'type'}\">" . $changeMappings{$aChange->{'type'}} . "</span>: $aChange->{'description'}</li>";
	}
	$changeContents .= "</ul>";
}

#	Do the replacement
$postContents =~ s/__VERSION_STRING__/$versionString/g;
$postContents =~ s/__NOW_DATE__/$nowDate/g;
$postContents =~ s/__RELEASE_NOTES_CONTENTS__/$changeContents/;

# Write the contents to the post file
$nowDate =~ s/^([0-9-]+) .+$/$1/;
my $postFilePath = $sitePath . "source/_posts/$nowDate-$postName.markdown";
do {
	open my $fh, ">", $postFilePath
		or die "Could not open file $postFilePath for output: $!";
	print $fh $postContents;
}

