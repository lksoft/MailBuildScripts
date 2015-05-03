#!/bin/sh

if [[ -f "$SRCROOT/lksitedirty.flag" ]]; then
	echo "Not posting build URL to Slack"
    exit 1;
fi

VERSION=`cat "$TEMP_VERSION_STRING_PATH"`

echo "Posting build URL to LKS Slack"
curl -X POST "https://littleknown.slack.com/services/hooks/slackbot?token=KIaU8DnZuVhsjIjNTU3ShIRx&channel=%23builds" -d "New Build of $MAIN_PRODUCT_NAME $VERSION ($1): http://media.littleknownsoftware.com/$PRODUCT_CODE/$MAIN_PRODUCT_NAME.$VERSION.dmg" -m 30 -s

echo "Posting build URL to LKS Slack"
curl -X POST "https://indev.slack.com/services/hooks/slackbot?token=Clnt0J7gPsIWnkpkGwJRN7vw&channel=%23newbuilds" -d "New $1 *LKS Build* of $MAIN_PRODUCT_NAME $VERSION : http://media.littleknownsoftware.com/$PRODUCT_CODE/$MAIN_PRODUCT_NAME.$VERSION.dmg" -m 30 -s
