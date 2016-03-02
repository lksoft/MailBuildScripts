#!/usr/bin/perl -w

#  AddJSONConfig.pl
#  Tealeaves
#
#  Created by Scott Little on 4/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;
#use Cwd qw/abs_path/;
use File::Basename;
use JSON qw/decode_json/;


my $dirName = dirname(__FILE__);
my $productCode;
my $productName;
my $versionString;
my $extraReleasePathValue = '';
my $repoDirectory;
my $minOSVersion = '';
my $secureHostPath = 's3.amazonaws.com/dl.smallcubed.com';
my $imageCDN = 'https://s3.amazonaws.com/media.smallcubed.com';
my $gitCommand = "/usr/local/bin/git";

$productName = $ENV{"MAIN_PRODUCT_NAME"};
if ($ENV{"COMPACT_PRODUCT_NAME"}) {
	$productName = $ENV{"COMPACT_PRODUCT_NAME"};
}
$productCode = $ENV{"PRODUCT_CODE"};
$versionString = `cat "$ENV{TEMP_VERSION_STRING_PATH}"`;
if ($ENV{"EXTRA_RELEASE_PATH"}) {
	$extraReleasePathValue = $ENV{"EXTRA_RELEASE_PATH"};
}
$repoDirectory = $ENV{"SRCROOT"};
if ($ENV{"MIN_OS_VERSION"}) {
	$minOSVersion = $ENV{"MIN_OS_VERSION"};
}

# Set variables depending on build type
my $machine = "smallcubed.com";
my $feedQuery = '';
my $releaseNotesQuery = '';
my $subPath = 'releases';
my $feedPathSupplement = '';
my $outgoingFileNameBase = 'mpinstall';
my @feedTypes = ('standard', 'mpinstall');
if ($ENV{"BUILD_TYPE"} eq "BETA") {
	@feedTypes = ('mpinstall-beta');
	$feedQuery = '?isBeta=1';
	$releaseNotesQuery = '?isBeta=1';
	$subPath = 'publicBeta';
	$outgoingFileNameBase .= '-beta';
}
elsif ($ENV{"BUILD_TYPE"} eq "TEST") {
	@feedTypes = ('mpinstall-test');
	$releaseNotesQuery = '?isTest=1';
	$machine = "test.". $machine;
	$subPath = 'bugs';
	$feedPathSupplement = '-test';
	$outgoingFileNameBase .= '-test';
}
elsif ($ENV{"BUILD_TYPE"} ne "RELEASE") {
	print "The build type[". $ENV{"BUILD_TYPE"} ."] was invalid!\n";
	exit(1);
}

# Set our variables
# Date and build number
my $releaseTime = `date "+%a, %d %b %Y %H:%M:%S %z"`;
$releaseTime =~ s/^\s+|\s+$//g;
my $buildNumber = `cat $repoDirectory/buildNumber.txt`;
$buildNumber =~ s/^\s+|\s+$//g;

my $tarFilePathBase = $ENV{"SRCROOT"} . "/..$extraReleasePathValue/Releases/$productName.$versionString";
my $signingScriptPath = "$dirName/sign_update.rb";
my $privateKeyPath = '';
if ($ENV{"SPARKLE_KEY_PATH"}) {
	$privateKeyPath = $ENV{"SRCROOT"} . $ENV{"SPARKLE_KEY_PATH"};
}

# Load the site json file
my $jsonPath = $ENV{"PRODUCT_SITE_PATH"} ."/_data/$productCode.json";
my $productJSON = `cat "$jsonPath"`;
my $decoded = decode_json($productJSON);
my $logoName = $decoded->{'logo'};
my $mpmDescription = $decoded->{'mpm-description'};
my $purchaseURL = $decoded->{'purchase-url'};
my $price = $decoded->{'prices'}{'usd'};


# Ensure that we have a clean feeds folder in temp
my $tempFeedsFolder = $ENV{"TEMP_DIR"}. "/feeds";
if ( -e "$tempFeedsFolder" ) {

	my $foundFile = 0;
	opendir(DIR, "$tempFeedsFolder") or die $!;
	while (my $file = readdir(DIR)) {
		if ("$file" ne '.' && "$file" ne '..') {
			$foundFile = 1;
		}
	}
    closedir(DIR);
    
    if ($foundFile) {
		print `rm "$tempFeedsFolder/"*`;
	}
}
else {
	print "Creating folder: $tempFeedsFolder\n";
	mkdir "$tempFeedsFolder";
	if ( ! -e "$tempFeedsFolder" ) {
		print "Could not create temp feeds folder\n";
		exit(3);
	}
}

# Loop over the feed types
foreach my $feedType (@feedTypes) {

	my $extension = 'tar.bz2';
	my $feedPath = 'feed';
	my $outgoingFileName = 'standard.xml';
	if ("$feedType" ne "standard") {
		$extension = "mpinstall.$extension";
		$feedPath = 'feed-mpt';
		$outgoingFileName = "$outgoingFileNameBase.xml";
	}
	$feedPath .= $feedPathSupplement;
	my $tarFilePath = "$tarFilePathBase.$extension";
	# Get the current build's tar file Size in MB
	# 	to use them to set the CFBundleVersion value
	my $tarFileSize = `ls -ln "$tarFilePath"`;
	$tarFileSize =~ s/^([^ ]+)( +)([^ ]+)( +)([0-9]+)( +)([0-9]+)( +)([^ ]+)( +).+$/$9/g;
	$tarFileSize =~ s/^\s+|\s+$//g;

	# The hash for the sparkle thing
	my $sparkleHash = '';
	if ($privateKeyPath ne "") {
		$sparkleHash = `ruby "$signingScriptPath" "$tarFilePath" "$privateKeyPath"`;
		$sparkleHash =~ s/^\s+|\s+$//g;
	}

	my $feedContent = <<APPCAST;
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
    <mpm>
        <CFBundleIdentifier>com.smallcubed.$productName</CFBundleIdentifier>
        <CFBundleName>$productName</CFBundleName>
        <MPCProductDescription>$mpmDescription</MPCProductDescription>
        <MPCCompanyName>SmallCubed, Inc.</MPCCompanyName>
        <MPCCompanyURL>https://smallcubed.com</MPCCompanyURL>
        <MPCProductURL>https://smallcubed.com/$productCode</MPCProductURL>
        <MPCProductSupportURL>https://help.smallcubed.com</MPCProductSupportURL>
        <MPCProductStoreURL>$purchaseURL</MPCProductStoreURL>
        <MPCProductIconFileURL>$imageCDN/$logoName</MPCProductIconFileURL>
        <MPCProductDirectInstall>true</MPCProductDirectInstall>
        <MPCProductPrice>$price</MPCProductPrice>
    </mpm>
	<channel>
		<title>$productName $ENV{"BUILD_TYPE"} App Cast</title>
		<link>https://$machine/$feedPath/$productCode$feedQuery</link>
		<description>Most recent changes with links to updates.</description>
		<language>en</language>
			<item>
				<title>Version $versionString</title>
				<sparkle:releaseNotesLink xml:lang="en">https://$machine/change-info/$productCode$releaseNotesQuery</sparkle:releaseNotesLink>
				<pubDate>$releaseTime</pubDate>
				<enclosure url="https://$secureHostPath/$subPath/$productCode/$productName.$versionString.$extension" sparkle:version="$buildNumber" sparkle:shortVersionString="$versionString" length="$tarFileSize" type="application/octet-stream" sparkle:dsaSignature="$sparkleHash"/>
				<sparkle:minimumSystemVersion>$minOSVersion</sparkle:minimumSystemVersion>
			</item>
	</channel>
</rss>
APPCAST

	print $feedContent;
	my $outFilePath = "$tempFeedsFolder/$outgoingFileName";
	open my $fileHandle, ">", "$outFilePath" or die "touch $outFilePath: $!\n"; 
		print $fileHandle "$feedContent";
	close $fileHandle;


}










