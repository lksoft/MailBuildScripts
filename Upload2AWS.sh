#!/bin/sh

#  Upload2AWS.sh
#  Build Scripts
#
#  Created by Scott Little on 27/11/14.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

# Validate the input
SEND_FILE_PATH="$1"
APP_ABBREV="$2"


# Ensure the file exists
if [ ! -f "$SEND_FILE_PATH" ]; then
	echo "The path '$SEND_FILE_PATH' is not a valid file";
	exit 1;
fi

# Ensure that the app abbreviation is not empty
if [ -z "$APP_ABBREV" ]; then
	echo "You did not provide an App Code"
	exit 2;
fi

# Build S3 Path
S3_PATH="s3://media.littleknownsoftware.com/$APP_ABBREV/"

echo "Loading file: '$SEND_FILE_PATH' to AWS at '$S3_PATH'…"

# Put the file, overwriting if it exists already
/usr/local/bin/s3cmd --no-progress -P -f put "$SEND_FILE_PATH" "$S3_PATH"
