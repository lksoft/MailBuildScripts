#!/bin/sh

if [[ -f "$SRCROOT/lksitedirty.flag" ]]; then
	echo "Not posting build URL to Slack"
    exit 1;
fi

if [[ "$TESTING_DEPLOY" == "NO" ]]; then
	echo "Testing deploy, so skipping Slack posting"
	exit 0;
fi

VERSION=`cat "$TEMP_VERSION_STRING_PATH"`

BUILD_NUM=" "
if [[ -f "$SRCROOT/buildNumber.txt" ]]; then
	BUILD_FILE_VALUE=`cat "$SRCROOT/buildNumber.txt"`
	BUILD_NUM=" (Build $BUILD_FILE_VALUE) "
fi


GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
GIT_HASH=`git rev-parse --short HEAD`
MESSAGE_STRING="*$BUILD_TYPE* $MAIN_PRODUCT_NAME build - $VERSION $BUILD_NUM[$GIT_BRANCH/$GIT_HASH]: https://media.littleknownsoftware.com/$PRODUCT_CODE/$MAIN_PRODUCT_NAME.$VERSION.dmg"

echo "Posting build URL to LKS Slack"
curl -X POST "https://littleknown.slack.com/services/hooks/slackbot?token=KIaU8DnZuVhsjIjNTU3ShIRx&channel=%23builds" -d "$MESSAGE_STRING" -m 30 -s

echo "Posting build URL to Indev Slack"
curl -X POST "https://indev.slack.com/services/hooks/slackbot?token=Clnt0J7gPsIWnkpkGwJRN7vw&channel=%23newbuilds" -d "$MESSAGE_STRING" -m 30 -s
