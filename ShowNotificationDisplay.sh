#!/bin/sh

#  ShowNotificationDisplay.sh
#  MailBuildScripts
#
#  Created by Scott Little on 6/3/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

MY_APP_DIR="${LOCAL_APPS_DIR}"
if [[ -d "${LOCAL_APPS_DIR}/Non-Store" ]]; then
	MY_APP_DIR="${LOCAL_APPS_DIR}/Non-Store"
fi
if [[ -d "${LOCAL_APPS_DIR}/Local" ]]; then
	MY_APP_DIR="${LOCAL_APPS_DIR}/Local"
fi

GROUP_NAME="none"
if [ "$#" == 3 ]; then
	GROUP_NAME="$3"
fi
if [ "$#" > 1 ]; then
	TITLE="$1"
	SUB_TITLE="$2"
else
	echo "Nothing to do"
	exit 0;
fi

echo "Title is $TITLE";
echo "SubTitle is $SUB_TITLE"
echo "Group is $GROUP_NAME"

if [[ -d "${MY_APP_DIR}/terminal-notifier.app" ]]; then
	"${MY_APP_DIR}/terminal-notifier.app/Contents/MacOS/terminal-notifier" -message "" -title "$TITLE" -subtitle "$SUB_TITLE" -group "$GROUP_NAME"
else
	echo "$SUB_TITLE"
fi


