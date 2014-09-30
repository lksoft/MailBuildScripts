#!/usr/bin/perl -w

#  ShowCommitHistory.pl
#  Tealeaves
#
#  Created by Scott Little on 4/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;
use Cwd qw/abs_path/;

my $repoDirectory = $ARGV[0];

my $gitCommand = "/usr/local/bin/git";
my $versionFileContents = "";
my $previousAndCurrentTags = `cd "$repoDirectory";$gitCommand describe --tags \`cd "$repoDirectory";$gitCommand rev-list --tags --abbrev=0 --max-count=2\` --abbrev=0`;
(my $previousTag = $previousAndCurrentTags) =~ s/^.+\n(.+)\s+/$1/g;
(my $currentTag = $previousAndCurrentTags) =~ s/^(.+)\n(.+)\s+/$1/g;
my $commitHistory = `cd "$repoDirectory";$gitCommand log $previousTag..$currentTag --pretty=format:"%s"`;
my $commitPattern = "^\\[(new|os|fix)\\]([\\s-]*)(.+)\$";
my $startLine = "\n";
foreach my $aLine (split /\n/, $commitHistory) {
	if ($aLine =~ m/$commitPattern/i) {
		my @values = $aLine =~ m/$commitPattern/i;
		$versionFileContents .= $startLine . '[' . lc($values[0]) . ']:"' . $values[2] . '"';
		$startLine = "\n";
	}
}

print $versionFileContents;
print "\n\n";
