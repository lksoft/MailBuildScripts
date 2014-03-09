#!/usr/bin/perl -w

#  TweetMessage.pl
#  Tealeaves
#
#  Created by Scott Little on 9/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

use strict;
use warnings;
use JSON qw( decode_json );

my $productCode;
my $productName;
my $versionString;
my $postPath = "";
my $shouldRetweet = 0;
my $argParseStart = 0;

if ($ENV{"MAIN_PRODUCT_NAME"}) {
	$productName = $ENV{"MAIN_PRODUCT_NAME"};
	$productCode = $ENV{"PRODUCT_CODE"};
	$versionString = $ENV{"VERSION_STRING"};
}
else {	#	For Command Line Testing purposes only!
	$productCode = $ARGV[0];
	$versionString = $ARGV[1];
	$productName = "Tealeaves";
	if ($productCode eq "sigpro") {
		$productName = "SignatureProfiler";
	}
	if ($productCode eq "mpm") {
		$productName = "MailPluginManager";
	}
	$argParseStart = 2;
}

#	Get passed in variables
my $argCount = scalar @ARGV;
if ($argCount > $argParseStart) {
	if ($ARGV[$argParseStart] =~ m/^(yes|no)$/i) {
		if (lc($ARGV[$argParseStart]) eq "yes") {
			$shouldRetweet = 1;
		}
		$argParseStart++;
	}
	if ($argCount > $argParseStart) {
		$postPath = $ARGV[$argParseStart];
	}
}

#	Test for valid productCode
my %accountNames = (
	"sis" => "TealeavesMail",
	"sigpro" => "sigprofiler",
	"test" => "wineglassapp",
	"badtest" => "notthere"
);
my @validCodes = keys %accountNames;
if (!($productCode ~~ @validCodes)) {
	print "Not tweeting for product ‘$productCode’\n";
	exit 0;
}

my $sitePath = "/Users/scott/Sites/lksite/";
my $accountName = $accountNames{$productCode};

#	Ensure that we really have an authorization for this account
my $accountInfo = `cd $sitePath;twurl accounts`;
if ($accountInfo !~ m/$accountName/) {
	print "Account ‘$accountName’ not found in twurl or twurl not installed.\n";
	exit 1;
}

#	Set the default account
`cd $sitePath;twurl set default $accountName`;

#	Build our message content
my $messageContent = "$productName has just been updated to version ‘$versionString’.";
if ($postPath ne "") {
	$messageContent .= " See this post about it => http://littleknownsoftware.com/blog/$postPath";
}
else {
	$messageContent .= " Download it here => http://littleknownsoftware.com/download/$productCode";
}

#	Send our message
print "Tweeting message\n";
my $tweetResult = `cd $sitePath;twurl /1.1/statuses/update.json -d "status=$messageContent"`;

#	Ensure that we really have an authorization for this account
my $lksAccount = "";
$accountInfo = `cd $sitePath;twurl accounts`;
if ($accountInfo =~ m/littleknown/) {
	$lksAccount = "littleknown";
}

#	Retweet if necessary
if ($shouldRetweet && ($lksAccount ne "")) {
	my $decoded = decode_json($tweetResult);
	if ($decoded->{"id_str"}) {
		my $firstTweetId = $decoded->{"id_str"};
		if ($firstTweetId ne "") {
			#	Change account and retweet
			`cd $sitePath;twurl set default $lksAccount`;
			print "Retweeting message: ‘$firstTweetId’\n";
			`cd $sitePath;twurl /1.1/statuses/retweet/$firstTweetId.json`;
		}
		else {
			print "Didn't get the tweet ID I expected to retweet:‘$firstTweetId’.\n";
		}
	}
}
