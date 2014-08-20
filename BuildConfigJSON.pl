#!/usr/bin/perl -w

#  BuildConfigJSON.pl
#  Tealeaves
#
#  Created by Scott Little on 3/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;

# Only do this if we have a final build indicator
if ($ENV{"PRODUCT_NAME"} ne "Publish Build") {
	print "Not making final build yet – skipping";
	return;
}

my $productCode;
my $productName;
my $versionString;
my $extraReleasePathValue = "";
my $packageExtension = ".dmg";
my $dmgFilePath;

if ($ENV{"MAIN_PRODUCT_NAME"}) {
	$productName = $ENV{"MAIN_PRODUCT_NAME"};
	if ($ENV{"COMPACT_PRODUCT_NAME"}) {
		$productName = $ENV{"COMPACT_PRODUCT_NAME"};
	}
	$productCode = $ENV{"PRODUCT_CODE"};
	$versionString = `cat "$ENV{TEMP_VERSION_STRING_PATH}"`;
	if ($ENV{"EXTRA_RELEASE_PATH"}) {
		$extraReleasePathValue = $ENV{"EXTRA_RELEASE_PATH"};
	}
	if ($ENV{"PACKAGE_EXTENSION"}) {
		$packageExtension = $ENV{"PACKAGE_EXTENSION"};
	}
	$dmgFilePath = $ENV{"SRCROOT"} . "/.." . $extraReleasePathValue . "/Releases/" . $productName . "." . $versionString . $packageExtension;
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
		$extraReleasePathValue = "/MPMPublic";
		$packageExtension = ".tar.bz2";
	}
	$dmgFilePath = "/Users/scott/Projects/Littleknown/" . $productName . $extraReleasePathValue . "/Releases/" . $productName . "." . $versionString . $packageExtension;
}

my $configDir = "/Users/scott/Sites/lksite/source/services/config";

my $versionDir = $configDir . "/version-info/" . $productCode;
my @fileList;
opendir(DIR, $versionDir) or die "Couldn't open folder for $productCode: $!";
while (defined(my $aFile = readdir(DIR))) {
	if ($aFile =~ /^([0-9]+)-(([0-9]+).)+([0-9a-b]+).json$/i) {
		push (@fileList, $aFile);
	}
}
closedir(DIR);

# Reverse sort file list
my @orderedFileList = sort { 
	my @bBuildNum = split('-', $b);
	my @aBuildNum = split('-', $a);
	my $bValue = 0 + $bBuildNum[0];
	my $aValue = 0 + $aBuildNum[0];
	$bValue <=> $aValue;
	} @fileList;
# Get the contents of the files into a variable
my $versionFileContents = "";
foreach my $aFile (@orderedFileList) {
	my $document = do {
		local $/ = undef;
		open my $fh, "<", ($versionDir . "/" . $aFile)
			or die "could not open $aFile: $!";
		<$fh>;
	};
	$versionFileContents .= $document;
}

# Get the current build's DMG file Size in MB
# 	to use them to set the CFBundleVersion value
my $dmgSize = `ls -ln "$dmgFilePath"`;
$dmgSize =~ s/^([^ ]+)( +)([^ ]+)( +)([0-9]+)( +)([0-9]+)( +)([^ ]+)( +).+$/$9/g;
$dmgSize = sprintf("%.1f", $dmgSize / (1024 * 1024));

# Get the contents as an XML format
my $templatePath = $configDir . "/version-info/" . $productCode . "-template.json";
my $template = do {
	local $/ = undef;
	open my $fh, "<", $templatePath
		or die "Could not open $templatePath for reading: $!";
	<$fh>;
};

# replace both the file size and the new contents
$template =~ s/__PRODUCT_CODE__/$productCode/;
$template =~ s/__DMG_FILE_SIZE_IN_MB__/$dmgSize/;
$template =~ s/__NEW_VERSION_INFO_LIST__/$versionFileContents/;

my $finalJSONFile = $configDir . "/" . $productCode . ".json";
# Rewrite the contents to the file
do {
	open my $fh, ">", $finalJSONFile
		or die "Could not open file $finalJSONFile for output: $!";
	print $fh $template;
}

