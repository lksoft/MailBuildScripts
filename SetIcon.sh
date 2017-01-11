#!/bin/sh

#  SetIcon.sh
#  Tealeaves
#
#  Created by Scott Little on 4/6/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

/usr/bin/SetFile -a C "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.$WRAPPER_EXTENSION"
"$SRCROOT/../MailBuildScripts/seticon" -d "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.$WRAPPER_EXTENSION/Contents/Resources/$PRODUCT_NAME.icns" "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.$WRAPPER_EXTENSION"
/usr/bin/SetFile -a BE "$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.$WRAPPER_EXTENSION"
exit 0
