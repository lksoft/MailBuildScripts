#!/usr/bin/perl -w
# 
#  ReleaseNotesAsHTML.pl
#  BuildScripts
#
#  Created by Scott Little on 29/2/2016.
#  Copyright (c) 2016 Little Known Software. All rights reserved.

use strict;
use warnings;
use 5.010;
use JSON qw/decode_json/;

my $productCode = $ARGV[0];
my $versionString = $ARGV[1];
my $sitePath = $ARGV[2];
my $supInfoPath = $ARGV[3];

# Get the release notes from the repo
my $isReleaseBuild = 'false';
if ($ENV{"BUILD_TYPE"} eq "RELEASE") {
	$isReleaseBuild = 'true';
}
my $repoDirectory = $ENV{"SRCROOT"};
my $gitCommand = "/usr/local/bin/git";
my $versionFileContents = "";
my $previousAndCurrentTags = `cd "$repoDirectory";$gitCommand describe --tags \`cd "$repoDirectory";$gitCommand rev-list --tags --abbrev=0 --max-count=2\` --abbrev=0`;
(my $previousTag = $previousAndCurrentTags) =~ s/^.+\n(.+)\s+/$1/g;
(my $currentTag = $previousAndCurrentTags) =~ s/^(.+)\n(.+)\s+/$1/g;
if ($isReleaseBuild eq 'false') {
	$previousTag = $currentTag;
	$currentTag = "HEAD";
}
my $commitHistory = `cd "$repoDirectory";$gitCommand log $previousTag..$currentTag --pretty=format:"%s"`;
my $commitPattern = "^\\[(new|os|fix)\\]([\\s-]*)(.+)\$";
my @changeList = ();
foreach my $aLine (split /\n/, $commitHistory) {
	if ($aLine =~ m/$commitPattern/i) {
		my @values = ($aLine =~ m/$commitPattern/i);
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
		my $type = lc($values[0]);
		my %infoHash = ('type' => $type, 'description' => $cleanedLine);
		push(@changeList, \%infoHash);
	}
}

#	Get the release notes into a replacing format
my %stringMappings;
my $stringJSONFilePath = "$sitePath/_data/strings.json";
if ( -f "$stringJSONFilePath" ) {
	my $stringContent = do {
		local $/ = undef;
		open my $fh, "<", $stringJSONFilePath
			or die "could not open $stringJSONFilePath: $!";
		<$fh>;
	};
	$stringContent =~ s/\n//g;
	my $decoded = decode_json($stringContent);
	%stringMappings = %{ $decoded->{'en'} };
};

# Get the contents of the warning or info into a variable
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

my $changeContents = "";
# Sort the items by the order
my @orderedChangeList = sort {
	$stringMappings{$a->{'type'}}{'order'} <=> $stringMappings{$b->{'type'}}{'order'}
} @changeList;
# Get the contents of the changes into a variable
$changeContents = "$supplementalInfoText<ul class=\"new-features\">";
foreach my $aChange (@orderedChangeList) {
	$changeContents .= "<li><span class=\"change-type $aChange->{'type'}\">" . $stringMappings{$aChange->{'type'}}{'text'} . "</span>: $aChange->{'description'}</li>";
}
$changeContents .= "</ul>";
	
print $changeContents;
