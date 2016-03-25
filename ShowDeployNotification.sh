#!/bin/sh

#  ShowDeployNotification.sh
#  MailBuildScripts
#
#  Created by Scott Little on 1/2/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

# Run script to show line count in Notifications

VERSION=`cat "$TEMP_VERSION_STRING_PATH"`
if [[ "$TESTING_DEPLOY" == "NO" ]]; then
	MY_TITLE="$MAIN_PRODUCT_NAME $BUILD_TYPE Deployed"
	MY_TEXT="Version $VERSION published!"
else
	MY_TITLE="$MAIN_PRODUCT_NAME $BUILD_TYPE Not Deployed"
	MY_TEXT="Version $VERSION built for test!"
fi

MY_DIR=`dirname "$0"`
"$MY_DIR/ShowNotificationDisplay.sh" "$MY_TITLE" "$MY_TEXT" "deployment"



