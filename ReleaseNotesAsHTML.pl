#!/usr/bin/perl -w

#  ReleaseNotesAsHTML.pl
#  Generic
#
#  Created by Scott Little on 29/2/2016.
#  Copyright (c) 2016 Little Known Software. All rights reserved.

use strict;
use warnings;
use 5.010;
use JSON qw( decode_json );

my $productCode = $ARGV[0];
my $versionString = $ARGV[1];
my $sitePath = $ARGV[2];
my $supInfoPath = $ARGV[3];

#	Get the release notes into a replacing format
my $versionJSON;
my $JSONFileDIR = "$sitePath/_product/$productCode";
if (opendir(DIR, $JSONFileDIR)) {
	while (defined(my $aFile = readdir(DIR))) {
		if ($aFile =~ m/$versionString\.json$/i) {
			$versionJSON = do {
				local $/ = undef;
				open my $fh, "<", ($JSONFileDIR . "/" . $aFile)
					or die "Could not open $aFile for reading: $!";
				<$fh>;
			};
			last;
		}
	}
	closedir(DIR);
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
my $supplementalInfoFile = "supInfoPath";
if ( -f "$supplementalInfoFile" ) {
	$supplementalInfoText = do {
		local $/ = undef;
		open my $fh, "<", $supplementalInfoFile
			or die "could not open $supplementalInfoFile: $!";
		<$fh>;
	};
	$supplementalInfoText =~ s/\n//g;
};

my $changeContents = "";
if (defined $versionJSON) {
	$versionJSON =~ s/^\s+|,\s+$//g;
	my $decoded = decode_json($versionJSON);
	my @changeList = @{ $decoded->{"lang"}{"en"}{"changes"} };
	
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
	
}

print $changeContents;

