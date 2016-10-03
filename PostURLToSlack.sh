#!/bin/sh

if [[ "$TESTING_DEPLOY" == "YES" ]]; then
	echo "Testing deploy, so skipping Slack posting"
	exit 0;
fi

VERSION=`cat "$TEMP_VERSION_STRING_PATH"`

BUILD_NUM=" "
if [[ -f "$SRCROOT/buildNumber.txt" ]]; then
	BUILD_FILE_VALUE=`cat "$SRCROOT/buildNumber.txt"`
	BUILD_NUM=" (Build $BUILD_FILE_VALUE) "
fi

SUB_PATH="release"
if [[ "$BUILD_TYPE" == "BETA" ]]; then
	SUB_PATH="beta"
elif [[ "$BUILD_TYPE" == "TEST" ]]; then
	SUB_PATH="bug"
elif [[ "$BUILD_TYPE" != "RELEASE" ]]; then
	echo "The build type[$BUILD_TYPE] was invalid!\n"
	exit 1;
fi

VERSIONED_PRODUCT_NAME="$MAIN_PRODUCT_NAME.$VERSION"
if [[ "$COMPACT_PRODUCT_NAME" != "" ]]; then
	VERSIONED_PRODUCT_NAME="$COMPACT_PRODUCT_NAME.$VERSION"
fi

GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
GIT_HASH=`git rev-parse --short HEAD`
MESSAGE_STRING="*$BUILD_TYPE* $MAIN_PRODUCT_NAME build - $VERSION $BUILD_NUM[$GIT_BRANCH/$GIT_HASH]: https://s3.amazonaws.com/media.smallcubed.com/$SUB_PATH/$PRODUCT_CODE/$VERSIONED_PRODUCT_NAME.dmg"

echo "Posting build URL to LKS Slack"
curl -X POST "https://littleknown.slack.com/services/hooks/slackbot?token=KIaU8DnZuVhsjIjNTU3ShIRx&channel=%23builds" -d "$MESSAGE_STRING" -m 30 -s

echo "Posting build URL to Indev Slack"
curl -X POST "https://smallcubed.slack.com/services/hooks/slackbot?token=Clnt0J7gPsIWnkpkGwJRN7vw&channel=%23newbuilds" -d "$MESSAGE_STRING" -m 30 -s
