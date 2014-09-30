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
my $gitCommand = "/usr/local/bin/git";
my $shouldFail = 0;
my $testMaster = `cd $lksiteDir;$gitCommand rev-parse --abbrev-ref HEAD`;
my $testClean = `cd $lksiteDir;$gitCommand status --porcelain`;
$testMaster =~ s/^\s+|\s+$//g;
$testClean =~ s/^\s+|\s+$//g;
if ($testClean ne "") {
	$shouldFail = 3;
	print "LKSite repo branch [$testMaster] has uncommited/new files.\n";
}

#	If we have an issue, write file and exit with error
if ($shouldFail != 0) {
	writeFlagFile($flagFilePath);
	exit $shouldFail;
}

#	Then try to make a new tag (via git flow)
my $latestCurrentTag = `cd $lksiteDir;$gitCommand describe --tags --abbrev=0`;
$latestCurrentTag =~ s/^tag+//g;
my $newTag = 1 + $latestCurrentTag;
print "Trying to create a new release branch with git-flow\n";
`cd $lksiteDir;$gitCommand flow release start $newTag`;
my $verifyTag = `cd $lksiteDir;$gitCommand rev-parse --abbrev-ref HEAD`;
$verifyTag =~ s/^\s+|\s+$//g;
my $shouldBeTag = "release/$newTag";
if ($verifyTag ne $shouldBeTag) {
	print "The release branch ($shouldBeTag) was not made correctly:($verifyTag)\n";
	writeFlagFile($flagFilePath);
	exit 4;
}

exit 0;
