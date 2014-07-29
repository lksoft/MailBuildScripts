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
my $lksiteDir = "/Users/scott/Sites/lksite";

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

#	Check to see if current repo is dirty or not
my $shouldFail = 0;
my $testMaster = `cd $lksiteDir;git rev-parse --abbrev-ref HEAD`;
my $testClean = `cd $lksiteDir;git status --porcelain`;
$testMaster =~ s/^\s+|\s+$//g;
$testClean =~ s/^\s+|\s+$//g;
if ($testClean ne "") {
	$shouldFail = 3;
	print "LKSite repo branch [$testMaster] has uncommited/new files.\n";
}

#	Then check the repo directory to see if we are on master, change if we can
if (($shouldFail == 0) and ($testMaster ne "master")) {
	print "Trying to change repo to master.\n";
	`cd $lksiteDir;git checkout master`;
	$testMaster = `cd $lksiteDir;git rev-parse --abbrev-ref HEAD`;
	$testMaster =~ s/^\s+|\s+$//g;
	if ($testMaster ne "master") {
		$shouldFail = 4;
		print "LKSite repo is not currently master => '$testMaster'.\n";
	}
}

#	If we have an issue, write file and exit with error
if ($shouldFail != 0) {
	writeFlagFile($flagFilePath);
	exit $shouldFail;
}

#	Now update master to the latest and make sure there were no issues
print "Updating from Remote.\n";
`cd $lksiteDir;git remote update origin`;
my $isAhead = `cd $lksiteDir;git status -s -u no`;
if ( ! -z $isAhead ) {
	print "Pulling into local master.\n";
	`cd $lksiteDir;git pull origin`;
}

exit 0;
