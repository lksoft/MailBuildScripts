#!/usr/bin/perl -w

#  AddJSONConfig.pl
#  Tealeaves
#
#  Created by Scott Little on 4/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;
use Cwd;

# Only do this if we have a final build indicator
if ($ENV{"PRODUCT_NAME"} eq "Publish Build") {
	print "Not making final build yet – skipping";
	return;
}

my $productCode;
my $productName;
my $versionString;
my $extraReleasePathValue = "";
my $tarFilePath;
my $repoDirectory;
my $signingScriptPath = cwd() . "/sign_update.rb";
my $privateKeyPath = "";

if ($ENV{"MAIN_PRODUCT_NAME"}) {
	$productName = $ENV{"MAIN_PRODUCT_NAME"};
	if ($ENV{"COMPACT_PRODUCT_NAME"}) {
		$productName = $ENV{"COMPACT_PRODUCT_NAME"};
	}
	$productCode = $ENV{"PRODUCT_CODE"};
	$versionString = $ENV{"VERSION_STRING"};
	if ($ENV{"EXTRA_RELEASE_PATH"}) {
		$extraReleasePathValue = $ENV{"EXTRA_RELEASE_PATH"};
	}
	$tarFilePath = $ENV{"SRCROOT"} . "/.." . $extraReleasePathValue . "/Releases/" . $productName . "." . $versionString . ".tar.bz2";
	$repoDirectory = $ENV{"SRCROOT"};
	if ($ENV{"SPARKLE_KEY_PATH"}) {
		$privateKeyPath = $ENV{"SRCROOT"} . $ENV{"SPARKLE_KEY_PATH"};
	}
}
else {	#	For Command Line Testing purposes only!
	my $projectDir = "/Users/scott/Projects/Littleknown/";
	$productCode = $ARGV[0];
	$versionString = $ARGV[1];
	$productName = "Tealeaves";
	$privateKeyPath = $projectDir . $productName . "/" . $productName . "/" . $productName . "/Project/";
	if ($productCode eq "sigpro") {
		$productName = "SignatureProfiler";
		$privateKeyPath = $projectDir . "SigProMaint/" . $productName . "/Project/";
	}
	$privateKeyPath .= "dsa_priv.pem";
	if ($productCode eq "mpm") {
		$productName = "MailPluginManager";
		$extraReleasePathValue = "/MPMPublic";
		$privateKeyPath = "";
	}
	$tarFilePath = $projectDir . $productName . $extraReleasePathValue . "/Releases/" . $productName . "." . $versionString . ".tar.bz2";
	$repoDirectory = $projectDir . $productName;
}

if ($privateKeyPath ne "") {
	die "$0: The Private key for the Sparkle signature is not available." unless -f $privateKeyPath;
}

my $configDir = "/Users/scott/Sites/lksite/source/services/config";
my $versionDir = $configDir . "/version-info/" . $productCode;

# Get the contents of the template into a variable
my $templateFile = $configDir . "/version-info/version-template.json";
my $templateContents = do {
	local $/ = undef;
	open my $fh, "<", $templateFile
		or die "could not open $templateFile: $!";
	<$fh>;
};

# Set our variables
# Get the current build's tar file Size in MB
# 	to use them to set the CFBundleVersion value
my $tarFileSize = `ls -ln $tarFilePath`;
$tarFileSize =~ s/^([^ ]+)( +)([^ ]+)( +)([0-9]+)( +)([0-9]+)( +)([^ ]+)( +).+$/$9/g;
$tarFileSize =~ s/^\s+|\s+$//g;
# Date and build number
my $dateTime = `date "+%d %b %Y %H:%M:%S"`;
$dateTime =~ s/^\s+|\s+$//g;
my $buildNumber = `cd $repoDirectory;git log --pretty=format:'' | wc -l | sed 's/[ \t]//g'`;
$buildNumber =~ s/^\s+|\s+$//g;
# The hash for the sparkle thing
my $sparkleHash = "";
if ($privateKeyPath ne "") {
	my $justHash = `ruby $signingScriptPath $tarFilePath $privateKeyPath`;
	$justHash =~ s/^\s+|\s+$//g;
	$sparkleHash = '      "sparkle-dsa-sig": "'. $justHash . '",';
	$sparkleHash =~ s/^|\s+$//g;
}

my $versionFileContents = "";
my $previousAndCurrentTags = `cd $repoDirectory;git describe --tags \`cd $repoDirectory;git rev-list --tags --abbrev=0 --max-count=2\` --abbrev=0`;
(my $previousTag = $previousAndCurrentTags) =~ s/^.+\n(.+)\s+/$1/g;
(my $currentTag = $previousAndCurrentTags) =~ s/^(.+)\n(.+)\s+/$1/g;
my $commitHistory = `cd $repoDirectory;git log $previousTag..$currentTag --pretty=format:"%s"`;
my $commitPattern = "^\\[(new|os|fix)\\]([\\s-]*)(.+)\$";
my $startLine = "\n";
foreach my $aLine (split /\n/, $commitHistory) {
	if ($aLine =~ m/$commitPattern/i) {
		my @values = $aLine =~ m/$commitPattern/i;
		$versionFileContents .= $startLine . '            {"type":"' . lc($values[0]) . '","description":"' . $values[1] . '"}';
		$startLine = ",\n";
	}
}

# replace both the file size and the new contents
$templateContents =~ s/__BUILD_VERSION__/$buildNumber/;
$templateContents =~ s/__VERSION_STRING__/$versionString/;
$templateContents =~ s/__FULL_DATE_TIME__/$dateTime/;
$templateContents =~ s/__TAR_FILE_SIZE_IN_BYTES__/$tarFileSize/;
$templateContents =~ s/__SPARKLE_DSA_HASH__/$sparkleHash/;
$templateContents =~ s/__CHANGE_LIST__/$versionFileContents\n          /;

my $finalJSONFile = $configDir . "/version-info/" . $productCode . "/" . $buildNumber . "-" . $versionString . ".json";
# Rewrite the contents to the file
do {
	open my $fh, ">", $finalJSONFile
		or die "Could not open file $finalJSONFile for output: $!";
	print $fh $templateContents;
}

