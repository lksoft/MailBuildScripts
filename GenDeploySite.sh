#!/bin/bash

#  GenDeploySite.sh
#  Tealeaves
#
#  Created by Scott Little on 6/3/2014.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

if [[ -f "$SRCROOT/lksitedirty.flag" ]]; then
    echo "Not deploying LKSite!"
    exit 1;
fi

cd "/Users/scott/sites/lksite"
echo "Generating LKSite"
rake generate
echo "Deploying LKSite"
#rake deploy
