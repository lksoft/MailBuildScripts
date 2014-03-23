#!/bin/sh

#  UpdateMPMPublic.sh
#  Build Scripts
#
#  Created by Scott Little on 12/10/13.
#  Copyright (c) 2013 Little Known Software. All rights reserved.

echo $ACTION

#	Ignore if we are cleaning
if [ -n $ACTION ]; then
	if [ "$ACTION" == "clean" ]; then
		exit 0
	fi
fi

#	Set the locations
export MY_TOP_LEVEL="$SRCROOT/.."
export MY_MPM_REPO_NAME="MPMPublic"
export MY_ALT_MPM_REPO_NAME="MailPluginManager"
export MY_MPM_REPO="$MY_TOP_LEVEL/$MY_MPM_REPO_NAME"

#	Go into the MPMPublic folder and ensure that it is up-to-date
if [ ! -d "$MY_MPM_REPO" ]; then
	export MY_MPM_REPO="$MY_TOP_LEVEL/$MY_ALT_MPM_REPO_NAME"
	export TEMP="$MY_ALT_MPM_REPO_NAME"
	export MY_ALT_MPM_REPO_NAME="$MY_MPM_REPO_NAME"
	export MY_MPM_REPO_NAME="$TEMP"
fi
if [ ! -d "$MY_MPM_REPO" ]; then
	echo "MPM Update Script ERROR - Neither of the $MY_MPM_REPO_NAME nor $MY_ALT_MPM_REPO_NAME submodules exist!!"
	exit 1
fi
cd "$MY_MPM_REPO"

git checkout -q master
BRANCH=`git rev-parse --abbrev-ref HEAD`
IS_CLEAN=`git status --porcelain`
if [ "$BRANCH" != "master" ]; then
	echo "MPM Update Script ERROR - $MY_MPM_REPO_NAME needs to be on the master branch"
	echo "Current branch is:'$BRANCH'"
	echo "Clean status is:$IS_CLEAN"
	exit 2
fi
if [[ "$IS_CLEAN" != "" ]]; then
	echo "MPM Update Script ERROR - $MY_MPM_REPO_NAME needs have a clean status"
	echo "Clean status is:'$IS_CLEAN'"
	exit 3
fi
git pull origin master

