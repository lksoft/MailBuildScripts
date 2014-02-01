#!/bin/sh

#  ShowLineCount.sh
#  MailBuildScripts
#
#  Created by Scott Little on 1/2/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

# Run script to show line count in Notifications

MY_APP_DIR="${LOCAL_APPS_DIR}"
if [[ -d "${LOCAL_APPS_DIR}/Non-Store" ]]; then
	MY_APP_DIR="${LOCAL_APPS_DIR}/Non-Store"
fi
if [[ -d "${LOCAL_APPS_DIR}/Local" ]]; then
	MY_APP_DIR="${LOCAL_APPS_DIR}/Local"
fi

LINE_COUNT=`find "${SRCROOT}" -name "*.m" -print0 | xargs -0 cat | wc -l`

MY_TEXT="Total source code lines: $LINE_COUNT"

if [[ -d "${MY_APP_DIR}/terminal-notifier.app" ]]; then
	"${MY_APP_DIR}/terminal-notifier.app/Contents/MacOS/terminal-notifier" -message "" -title "XCode Build Line Count" -subtitle "$MY_TEXT" -group linecount
else
	echo "$MY_TEXT"
fi


