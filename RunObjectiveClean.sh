#!/bin/sh

#  RunObjectiveClean.sh
#  MailBuildScripts
#
#  Created by Scott Little on 1/2/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

# Run script to raise warnings about the code formatting
#	but only if it is a development build

echo "Configuration is: $CONFIGURATION"

if [[ "$CONFIGURATION" != Release* ]]; then
	echo "Skipping Objective-Clean step"
	exit 0;
fi

if [[ -z ${SKIP_OBJCLEAN} || ${SKIP_OBJCLEAN} != 1 ]]; then
	if [[ -d "${LOCAL_APPS_DIR}/Objective-Clean.app" ]]; then
		"${LOCAL_APPS_DIR}"/Objective-Clean.app/Contents/Resources/ObjClean.app/Contents/MacOS/ObjClean "${SRCROOT}${OBJC_CLEAN_EXCLUDE_PREFIX}"
		
	else
		echo "warning: You have to install and set up Objective-Clean to use its features!"
	fi
fi
