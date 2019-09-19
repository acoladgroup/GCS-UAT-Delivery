#!/bin/bash
###########################################################################################
# Script purpose: Undeploy a retired application
# Author: Nicolas Goyet - AMPLEXOR
# Change date: 08/2019
# Usage: ./undeployedRetiredVersion.sh <APP_NAME>
#				APP_NAME : Name of the application
###########################################################################################

# Check for input arguments
if [ "$#" -ne 1 ]; then
	echo "Usage: ./undeployedRetiredApp.sh <APP_NAME>"
	echo "Application is not retired"
	exit -1
fi

echo "## Undeploy a retired application ##"
. $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
. ./scripts/setServerConfig.sh
echo "##environment loaded ##"

if [ "$1" == "PMWS" ]; then
	java weblogic.WLST ./scripts/undeployedRetiredApp.py $BPM_ADMIN_URL $BPM_ADMIN_LOGIN $BPM_ADMIN_PASSWORD $1
else
	java weblogic.WLST ./scripts/undeployedRetiredApp.py $APP_ADMIN_URL $APP_ADMIN_LOGIN $APP_ADMIN_PASSWORD $1
fi

echo "## Undeploy finished ##"
