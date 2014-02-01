#!/bin/sh

#  ShowTodosFixmes.sh
#  MailBuildScripts
#
#  Created by Scott Little on 1/2/2014.
#  Copyright (c) 2014 Little Known Software. All rights reserved.

# Run script to raise warnings if TODOs or FIXMEs exist
#	but only if it is a development build

echo "Configuration is: $CONFIGURATION"

if [[ "$CONFIGURATION" == "Release" ]]; then
	KEYWORDS="FIXME:|\?\?\?:|\!\!\!:"
	find "${SRCROOT}" \( -name "*.h" -or -name "*.m" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/ error: \$1/"
else
	KEYWORDS="TODO:|FIXME:|\?\?\?:|\!\!\!:"
	find "${SRCROOT}" \( -name "*.h" -or -name "*.m" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/ warning: \$1/"
fi

