#!/bin/bash

#  GenDeploySite.sh
#  Tealeaves
#
#  Created by Scott Little on 6/3/2014.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

source ~/.bash_profile

if [[ -f "$SRCROOT/lksitedirty.flag" ]]; then
    echo "Not deploying LKSite!"
    exit 1;
fi

if [[ -d "$PRODUCT_SITE_PATH" ]]; then
	cd "$PRODUCT_SITE_PATH"
	echo "Generating and Deploying LKSite to Live"
	rake -q gen_deploy_live
fi
