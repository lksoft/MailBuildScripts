#!/usr/bin/perl -w

#  AddJSONConfig.pl
#  Tealeaves
#
#  Created by Scott Little on 4/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;
use Cwd qw/abs_path/;

# Only do this if we have a final build indicator
if ($ENV{"PRODUCT_NAME"}) {
 	if ((!$ARGV[0] or ($ARGV[0] ne "build_test")) and ($ENV{"PRODUCT_NAME"} ne "Publish Build")) {
		print "Not making final build yet – skipping";
		exit;
	}
	elsif ($ENV{"BETA"} eq "YES") {
		print "Creating JSON Config for BETA!";
	}
	elsif ($ARGV[0] eq "build_test") {
		print "Creating JSON Config for build test!";
	}
}

#	If the lksite is not available, exit
my $lksiteDir = $ENV{"HOME"}."/Sites/lksite";
#	Test to see if site folder exists
if ( ! -d $lksiteDir ) {
	print "The lksite directory does not exist - skipping this step.\n";
	if ($ENV{"BETA"} eq "YES") {
		exit 0;
	}
	else {
		exit 1;
	}
}

my $productCode;
my $productName;
my $versionString;
my $extraReleasePathValue = "";
my $tarFilePath;
my $mpTarFilePath;
my $repoDirectory;
my ($realPath) = abs_path($0) =~ m/(.*)AddJSONConfig.pl/i;
my $signingScriptPath = $realPath . "sign_update.rb";
my $privateKeyPath = "";
my $minOSVersion = "";
my $betaIndicator = '';
my $supplementalInfoText = '';

if ($ENV{"BETA"} eq "YES") {
	$betaIndicator = '      "is-beta": "true",';
}

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
	$tarFilePath = $ENV{"SRCROOT"} . "/.." . $extraReleasePathValue . "/Releases/" . $productName . "." . $versionString . ".tar.bz2";
	$mpTarFilePath = $ENV{"SRCROOT"} . "/.." . $extraReleasePathValue . "/Releases/" . $productName . "." . $versionString . ".mpinstall.tar.bz2";
	$repoDirectory = $ENV{"SRCROOT"};
	if ($ENV{"SPARKLE_KEY_PATH"}) {
		$privateKeyPath = $ENV{"SRCROOT"} . $ENV{"SPARKLE_KEY_PATH"};
	}
	if ($ENV{"MIN_OS_VERSION"}) {
		$minOSVersion = '      "min-os-version": "'. $ENV{"MIN_OS_VERSION"} . '",';
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
	$mpTarFilePath = $projectDir . $productName . $extraReleasePathValue . "/Releases/" . $productName . "." . $versionString . ".mpinstall.tar.bz2";
	$repoDirectory = $projectDir . $productName;
}

if ($privateKeyPath ne "") {
	die "The Private key for the Sparkle signature is not available.\nPath: $privateKeyPath" unless -f $privateKeyPath;
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
my $gitCommand = "/usr/local/bin/git";
my $tarFileSize = `ls -ln "$tarFilePath"`;
$tarFileSize =~ s/^([^ ]+)( +)([^ ]+)( +)([0-9]+)( +)([0-9]+)( +)([^ ]+)( +).+$/$9/g;
$tarFileSize =~ s/^\s+|\s+$//g;
# Date and build number
my $dateTime = `date "+%d %b %Y %H:%M"`;
$dateTime =~ s/^\s+|\s+$//g;
my $buildNumber = `cd "$repoDirectory";$gitCommand log --pretty=format:'' | wc -l | sed 's/[ \t]//g'`;
$buildNumber =~ s/^\s+|\s+$//g;
# The hash for the sparkle thing
my $sparkleHash = "";
if ($privateKeyPath ne "") {
	my $justHash = `ruby "$signingScriptPath" "$tarFilePath" "$privateKeyPath"`;
	$justHash =~ s/^\s+|\s+$//g;
	$sparkleHash = '      "sparkle-dsa-sig": "'. $justHash . '",';
	$sparkleHash =~ s/^|\s+$//g;
}

my $versionFileContents = "";
my $previousAndCurrentTags = `cd "$repoDirectory";$gitCommand describe --tags \`cd "$repoDirectory";$gitCommand rev-list --tags --abbrev=0 --max-count=2\` --abbrev=0`;
(my $previousTag = $previousAndCurrentTags) =~ s/^.+\n(.+)\s+/$1/g;
(my $currentTag = $previousAndCurrentTags) =~ s/^(.+)\n(.+)\s+/$1/g;
if ($ENV{"BETA"} eq "YES") {
	$previousTag = $currentTag;
	$currentTag = "HEAD";
}
my $commitHistory = `cd "$repoDirectory";$gitCommand log $previousTag..$currentTag --pretty=format:"%s"`;
my $commitPattern = "^\\[(new|os|fix)\\]([\\s-]*)(.+)\$";
my $startLine = "\n";
foreach my $aLine (split /\n/, $commitHistory) {
	if ($aLine =~ m/$commitPattern/i) {
		my @values = $aLine =~ m/$commitPattern/i;
		my $counter = 0;
		my $cleanedLine = '';
		foreach my $quotedPart (split /\"/, $values[2]) {
			if (($counter % 2) == 1) {
				$cleanedLine .= "“$quotedPart”";
			}
			else {
				$cleanedLine .= $quotedPart;
			}
			$counter++;
		}
		$versionFileContents .= $startLine . '            {"type":"' . lc($values[0]) . '","description":"' . $cleanedLine . '"}';
		$startLine = ",\n";
	}
}

# setup values for the mpinstaller, if it is there
my $supportsMPInstall = '';
my $mpSparkleHash = '';
my $mpTarFileSize = '';
print "MPInstall Tar File:$mpTarFilePath";
if ( -f "$mpTarFilePath" ) {
	$supportsMPInstall = '      "supports-mpinstall": "true",';
	my $tempFileSize = `ls -ln "$mpTarFilePath"`;
	$tempFileSize =~ s/^([^ ]+)( +)([^ ]+)( +)([0-9]+)( +)([0-9]+)( +)([^ ]+)( +).+$/$9/g;
	$tempFileSize =~ s/^\s+|\s+$//g;
	$mpTarFileSize = '      "mpinstall-sparkle-size": '. $tempFileSize .',';
	if ($privateKeyPath ne "") {
		my $justHash = `ruby "$signingScriptPath" "$mpTarFilePath" "$privateKeyPath"`;
		$justHash =~ s/^\s+|\s+$//g;
		$mpSparkleHash = '      "mpinstall-sparkle-dsa-sig": "'. $justHash . '",';
		$mpSparkleHash =~ s/^|\s+$//g;
	}
}

# Get the contents of the warning or info into a variable
my $supplementalInfoFile = "$ENV{SUPPLEMENTAL_VERSION_INFO_PATH}";
if ( -f "$supplementalInfoFile" ) {
	$supplementalInfoText = do {
		local $/ = undef;
		open my $fh, "<", $supplementalInfoFile
			or die "could not open $supplementalInfoFile: $!";
		<$fh>;
	};
	$supplementalInfoText =~ s/\n//g;
	if ($supplementalInfoText ne "") {
		$supplementalInfoText = "\"info\": \"$supplementalInfoText\",";
	}
	
	#	If this is not a test run, then clear out the sup info file
	if ($ENV{"TESTING_DEPLOY"} eq "NO") {
		print "Emptying contents of Supplemental Version file.\n";
		my $nothing = `echo "" > "$supplementalInfoFile"`
	}
};

# replace both the file size and the new contents
$templateContents =~ s/__BUILD_VERSION__/$buildNumber/;
$templateContents =~ s/__VERSION_STRING__/$versionString/;
$templateContents =~ s/__FULL_DATE_TIME__/$dateTime/;
$templateContents =~ s/__TAR_FILE_SIZE_IN_BYTES__/$tarFileSize/;
$templateContents =~ s/__SPARKLE_DSA_HASH__/$sparkleHash/;
$templateContents =~ s/__MIN_OS_VERSION__/$minOSVersion/;
$templateContents =~ s/__CHANGE_LIST__/$versionFileContents\n          /;
$templateContents =~ s/__SUPPORTS_MP__/$supportsMPInstall/;
$templateContents =~ s/__MP_SPARKLE_DSA_HASH__/$mpSparkleHash/;
$templateContents =~ s/__MP_TAR_FILE_SIZE_IN_BYTES__/$mpTarFileSize/;
$templateContents =~ s/__IS_BETA__/$betaIndicator/;
$templateContents =~ s/__SUPPLEMENTAL_INFO_TEXT__/$supplementalInfoText/;

my $finalJSONFile = $configDir . "/version-info/" . $productCode . "/" . $buildNumber . "-" . $versionString . ".json";
# Rewrite the contents to the file
do {
	open my $fh, ">", $finalJSONFile
		or die "Could not open file $finalJSONFile for output: $!";
	print $fh $templateContents;
}

