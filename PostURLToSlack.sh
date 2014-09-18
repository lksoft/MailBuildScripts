#!/bin/sh

if [[ -f "$SRCROOT/lksitedirty.flag" ]]; then
	echo "Not posting build URL to Slack"
    exit 1;
fi

VERSION=`cat "$ENV{TEMP_VERSION_STRING_PATH}"`

echo "Posting build URL to Slack"
curl -X POST "https://littleknown.slack.com/services/hooks/slackbot?token=KIaU8DnZuVhsjIjNTU3ShIRx&channel=%23builds" -d "New Build of $MAIN_PRODUCT_NAME $VERSION ($1): http://media.littleknownsoftware.com/$PRODUCT_CODE/$MAIN_PRODUCT_NAME.$VERSION.dmg" -m 30 -v
