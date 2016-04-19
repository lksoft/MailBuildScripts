#!/usr/bin/perl -w

#  PublishPost.pl
#  Tealeaves
#
#  Created by Scott Little on 9/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;
use warnings;
use JSON qw/encode_json/;
use URI::Escape;
use File::Basename;

my $dirname = dirname(__FILE__);
my $productCode = $ENV{"PRODUCT_CODE"};
my $productName = $ENV{"MAIN_PRODUCT_NAME"};
my $uploadBuildInfoURL = $ENV{"BUILD_INFO_URL"};
my $compactProductName = $productName;
if ($ENV{"COMPACT_PRODUCT_NAME"}) {
	$compactProductName = $ENV{"COMPACT_PRODUCT_NAME"};
}
my $versionString = `cat "$ENV{TEMP_VERSION_STRING_PATH}"`;
my $buildNum = `cat "$ENV{SRCROOT}/buildNumber.txt"`;
my $buildType = $ENV{"BUILD_TYPE"};
my $sitePath = $ENV{"PRODUCT_SITE_PATH"};

# Load the site json file
my $minOS = $ENV{"MIN_OS_VERSION"};

# Get the current git branch and sha hash
# 	to use them to set the CFBundleVersion value
my $gitCommand = "/usr/local/bin/git";
my $gitBranch=`$gitCommand symbolic-ref --short -q HEAD`;
my $gitCommit=`$gitCommand rev-parse --short HEAD`;

# trim the ends
$gitBranch =~ s/\s+$//;
$gitCommit =~ s/\s+$//;


my $dmgURL = "https://sw.amazonaws.com.dl.smallcubed.com/$productCode/$compactProductName.$versionString.dmg";

my $changeContents = `"$dirname/ReleaseNotesAsJSON.pl"`;

my %release;
$release{'product'} = $productName;
$release{'code'} = $productCode;
$release{'build_type'} = $buildType;
$release{'version'} = $versionString;
$release{'build'} = $buildNum;
$release{'commit'} = $gitCommit;
$release{'branch'} = $gitBranch;
$release{'min_os'} = $minOS;
$release{'file_name'} = "$compactProductName.$versionString.dmg";
$release{'release_json'} = $changeContents;
my $json_package = encode_json(\%release);
$json_package = uri_escape_utf8($json_package);

my $result = `curl -s -L -X "POST" "$uploadBuildInfoURL" -H "Content-Type: application/json" -d "$json_package"`;

print $result;
