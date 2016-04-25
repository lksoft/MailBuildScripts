#!/usr/bin/perl -w

#  Upload2AWS.pl
#  Products
#
#  Created by Scott Little on 01/03/2016.
#  Copyright (c) 2016 Little Known Software. All rights reserved.

use strict;
use File::Basename;

# Defaults with environment variables
my $subFolder = "release";
if ($ENV{"BUILD_TYPE"}) {
	if ($ENV{"BUILD_TYPE"} eq "BETA") {
		$subFolder = "beta";
	}
	elsif ($ENV{"BUILD_TYPE"} eq "TEST") {
		$subFolder = "bug";
	}
}
my $bucketName = $ENV{"BUCKET_NAME"};
my $awsProfile = $ENV{"AWS_PROFILE_NAME"};

# Override with arguments
my $localPath = $ARGV[0];
my $fileName = $ARGV[1];
my $productCode = $ARGV[2];
if (scalar(@ARGV) > 3) {
	$subFolder = $ARGV[3];
}
if (scalar(@ARGV) > 4) {
	$bucketName = $ARGV[4];
}

# Construct any local variables
my $localFilePath = "$localPath/$fileName";
my $awsPath = "$bucketName/$subFolder/$productCode/$fileName";

#	Test to see if file exists
if ( ! -f $localFilePath ) {
	print "The path '$localFilePath' is not a valid file!";
	exit 1;
}

print "Uploading file: '$localFilePath' to AWS at '$awsPath'…\n";

my $dirName = dirname(__FILE__);
# Put the file, overwriting if it exists already
my $result = `"$dirName/aws" put "$awsPath" "$localFilePath" --aws-profile="$awsProfile"`;

print $result;
