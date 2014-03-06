#!/bin/sh

#  ShowLineCount.sh
#  MailBuildScripts
#
#  Created by Scott Little on 1/2/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

# Run script to show line count in Notifications

LINE_COUNT=`find "${SRCROOT}" -name "*.m" -print0 | xargs -0 cat | wc -l`
MY_TEXT="Total source code lines: $LINE_COUNT"
MY_TITLE="XCode Build Line Count"

MY_DIR=`dirname ${0}`
"$MY_DIR/ShowNotificationDisplay.sh" "$MY_TITLE" "$MY_TEXT" "linecount"
