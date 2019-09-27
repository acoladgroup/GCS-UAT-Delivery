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
echo "##environment loaded ##"

java weblogic.WLST ./scripts/undeployedRetiredApp.py ./scripts/serverInfo.properties $1

echo "## Undeploy finished ##"
