#!/bin/bash
###########################################################################################
# Script purpose: Deploy a new version of an Application
# Author: Nicolas Goyet - AMPLEXOR
# Change date: 08/2019
# Usage: ./deployApp.bat <APP_NAME> <EAR_FILE> <CONFIG_PLAN>
#				APP_NAME 		: Application name
#				EAR_FILE 		: File to deploy
#				CONFIG_PLAN 	: Config plan to use
###########################################################################################

# Check for input arguments
if [ "$1" == "PMWS" ] && [ "$#" -ne 2 ]; then
        echo "Usage: ./deployApp.sh <APP_NAME> <EAR_FILE>"
        echo "EAR file not deployed"
        exit -1
elif [ "$1" != "PMWS" ] && [ "$#" -ne 3 ]; then
        echo "Usage: ./deployApp.sh <APP_NAME> <EAR_FILE> <CONFIG_PLAN>"
        echo "EAR file not deployed"
        exit -1
fi

echo "## Deploy a new version of the application ##"
. $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
. ./scripts/serverInfo.properties

echo "##environment loaded ##"
	
if [ "$1" == "PMWS" ]; then
	java -classpath $ORACLE_HOME/wlserver/server/lib/weblogic.jar weblogic.Deployer -adminurl $ADF_BPM_URL -user $ADF_BPM_LOGIN -password $ADF_BPM_PASSWORD -redeploy -name $1 -source $2 -targets $ADF_BPM_TARGET -upload
else
	java -classpath $ORACLE_HOME/wlserver/server/lib/weblogic.jar weblogic.Deployer -adminurl $ADF_APP_URL -user $ADF_APP_LOGIN -password $ADF_APP_PASSWORD -redeploy -name $1 -source $2 -targets $ADF_APP_TARGET -plan $3 -upload
fi

echo "## End deployment ##"
