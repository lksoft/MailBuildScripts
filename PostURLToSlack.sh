#!/bin/sh

if [[ -f "$SRCROOT/lksitedirty.flag" ]]; then
	echo "Not posting build URL to Slack"
    exit 1;
fi

VERSION=`cat "$TEMP_VERSION_STRING_PATH"`
TYPE="RELEASE"

if [[ "$BETA" == "YES" ]]; then
	echo "Posting for a beta version"
	TYPE="BETA"
fi

GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
GIT_HASH=`git rev-parse --short HEAD`
VERSION_DESC="$VERSION [$GIT_BRANCH/$GIT_HASH]"

echo "Posting build URL to LKS Slack"
curl -X POST "https://littleknown.slack.com/services/hooks/slackbot?token=KIaU8DnZuVhsjIjNTU3ShIRx&channel=%23builds" -d "New Build of $MAIN_PRODUCT_NAME $VERSION_DESC ($TYPE): http://media.littleknownsoftware.com/$PRODUCT_CODE/$MAIN_PRODUCT_NAME.$VERSION.dmg" -m 30 -s

echo "Posting build URL to Indev Slack"
curl -X POST "https://indev.slack.com/services/hooks/slackbot?token=Clnt0J7gPsIWnkpkGwJRN7vw&channel=%23newbuilds" -d "New $TYPE *LKS Build* of $MAIN_PRODUCT_NAME $VERSION_DESC : http://media.littleknownsoftware.com/$PRODUCT_CODE/$MAIN_PRODUCT_NAME.$VERSION.dmg" -m 30 -s
