#!/usr/bin/perl -w

#  TestLKSiteIsMasterCleanAndUpToDate.pl
#  Tealeaves
#
#  Created by Scott Little on 6/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;

#	Testing
my $baseDir = ".";
if ($ENV{"SRCROOT"}) {
	$baseDir = $ENV{"SRCROOT"};
}

my $flagFilePath = "$baseDir/lksitedirty.flag";
my $lksiteDir = $ENV{"PRODUCT_SITE_PATH"};

sub writeFlagFile {
	my ($filePath) = @_;
	open my $fileHandle, ">>", "$filePath" or die "touch $filePath: $!\n"; 
		print $fileHandle "dummy";
	close $fileHandle;
}

#	Test to see if site folder exists
if ( ! -d $lksiteDir ) {
	print "The lksite directory does not exist - can't proceed.\n";
	writeFlagFile($flagFilePath);
	exit 1;
}

#	First remove any existing dirty flag file
if ( -f $flagFilePath ) {
	if (! unlink($flagFilePath)) {
		print "Trying to delete flag file:$!\n";
		exit 2;
	}
}

#	If this is a test run, then just write the file and leave
if ($ENV{"TESTING_DEPLOY"} eq "YES") {
	print "Continuing with a testing deploy.\n";
	exit 0;
}

#	Check to see if current repo is dirty or not
my $gitCommand = "/usr/local/bin/git";
my $testCurrent = `cd $lksiteDir;$gitCommand rev-parse --abbrev-ref HEAD`;
my $shouldFail = 0;
my $testClean = `cd $lksiteDir;$gitCommand status --porcelain`;
$testCurrent =~ s/^\s+|\s+$//g;
$testClean =~ s/^\s+|\s+$//g;
if ($testClean ne "") {
	$shouldFail = 3;
	print "LKSite repo branch [$testCurrent] has uncommited/new files.\n";
}

#	If we have an issue, write file and exit with error
if ($shouldFail != 0) {
	writeFlagFile($flagFilePath);
	exit $shouldFail;
}

#	Determine the next branch number
my $latestCurrentTag = `cd $lksiteDir;$gitCommand describe --tags --abbrev=0`;
$latestCurrentTag =~ s/^tag+//g;
my $newTag = 1 + $latestCurrentTag;
my $shouldBeTag = "release/$newTag";

#	If the current branch is the next tag branch, then assume that it is the correct one.
if ($testCurrent eq $shouldBeTag) {
	print "Next tag is already created and checked out";
	exit 0;
}

#	Otherwise try to make a new tag (via git flow)
print "Trying to create a new release branch with git-flow\n";
`cd $lksiteDir;$gitCommand flow release start $newTag`;
my $verifyTag = `cd $lksiteDir;$gitCommand rev-parse --abbrev-ref HEAD`;
$verifyTag =~ s/^\s+|\s+$//g;
if ($verifyTag ne $shouldBeTag) {
	print "The release branch ($shouldBeTag) was not made correctly:($verifyTag)\n";
	writeFlagFile($flagFilePath);
	exit 4;
}

exit 0;
