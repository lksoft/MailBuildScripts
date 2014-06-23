#!/usr/bin/perl -w

use strict;

die "$0: Must be run from Xcode" unless $ENV{"BUILT_PRODUCTS_DIR"};

unless ($ENV{"CONFIGURATION"} eq "Debug") {
	# Ensure that the proper values have been setup
	die "No Codesign identity found" unless $ENV{"CODE_SIGN_IDENTITY"};
}

# Get the current git branch and sha hash
# 	to use them to set the CFBundleVersion value
my $GIT_VERSION = `git log --pretty=format:'' | wc -l | sed 's/[ \t]//g'`;
my $INFO_SOURCE = "$ENV{SRCROOT}/CopyMoveHelper/CopyMoveHelper-Info.plist";
my $INFO_DEST = "$ENV{SRCROOT}/CopyMoveHelper/CopyMoveHelperFixed-Info.plist";

# Trim both sides
$GIT_VERSION =~ s/^\s+//;
$GIT_VERSION =~ s/\s+$//;

# Get the contents as an XML format
my $info = `plutil -convert xml1 -o - "$INFO_SOURCE"`;

# Always update the test client authorization
my $testClient = "<string>identifier com.littleknownsoftware.MPI.REPLACESUBID and certificate leaf[subject.CN] = &quot;CODESIGNID&quot;</string>";
unless ($ENV{"CONFIGURATION"} eq "DebugDevIDOwner") {
	$testClient = "";
}
$info =~ s/<string>\[TEST_AUTH_CLIENT\]<\/string>/$testClient/g;

unless ($ENV{"CONFIGURATION"} eq "Debug") {
	# replace both the branch name and the hash value
	$info =~ s/CODESIGNID/$ENV{"CODE_SIGN_IDENTITY"}/g;
	$info =~ s/\[GIT-BUILD-COUNT\]/$GIT_VERSION/g;

}

# Rewrite the contents to the file
open(FH, ">$INFO_DEST") or die "$0: $INFO_DEST: $!";
print FH $info;
close(FH);

