#!/usr/bin/perl -w

#  ReleaseNotesAsJSON.pl
#  MailBuildScripts
#
#  Created by Scott Little on 19/4/2016.
#  Copyright (c) 2016 Little Known Software. All rights reserved.

use strict;

my $isBetaBuild = 'false';
if (!$ENV{"BUILD_TYPE"}) {
	print "Script called invalidly, no BUILD_TYPE was set – skipping";
	exit 2;
}
if ($ENV{"BUILD_TYPE"} eq "BETA") {
	$isBetaBuild = 'true';
}

# Set our variables
# Get the current build's tar file Size in MB
# 	to use them to set the CFBundleVersion value
my $gitCommand = "/usr/local/bin/git";
my $repoDirectory = $ENV{"SRCROOT"};

my $versionFileContents = "";
my $previousAndCurrentTags = `cd "$repoDirectory";$gitCommand describe --tags \`cd "$repoDirectory";$gitCommand rev-list --tags --abbrev=0 --max-count=2\` --abbrev=0`;
(my $previousTag = $previousAndCurrentTags) =~ s/^.+\n(.+)\s+/$1/g;
(my $currentTag = $previousAndCurrentTags) =~ s/^(.+)\n(.+)\s+/$1/g;
if ($isBetaBuild) {
	$previousTag = $currentTag;
	$currentTag = "HEAD";
}
my $commitHistory = `cd "$repoDirectory";$gitCommand log $previousTag..$currentTag --pretty=format:"%s"`;
my $commitPattern = "^\\[(new|os|fix)\\]([\\s-]*)(.+)\$";
my $startLine = "";
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
		$versionFileContents .= $startLine . '{"type":"' . lc($values[0]) . '","description":"' . $cleanedLine . '"}';
		$startLine = ",";
	}
}

# Get the contents of the warning or info into a variable
my $supInfoPath = $ENV{"SUPPLEMENTAL_VERSION_INFO_PATH"};
my $supplementalInfoText = "";
if ( -f "$supInfoPath" ) {
	$supplementalInfoText = do {
		local $/ = undef;
		open my $fh, "<", $supInfoPath
			or die "could not open $supInfoPath: $!";
		<$fh>;
	};
	$supplementalInfoText =~ s/\n//g;
};

print '{"changes":['. $versionFileContents .'], "info":"'. $supplementalInfoText .'"}';
