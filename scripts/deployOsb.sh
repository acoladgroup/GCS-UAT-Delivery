#!/bin/bash
###########################################################################################
# Script purpose: Deploy OSB
# Author: Nicolas Goyet - AMPLEXOR
# Change date: 09/2019
# Usage: ./deployOsb.sh <OSB_FILE> <OSB_CUSTOMIZATIONFILE>
#				OSB_FILE 	: OSB sbar
#				OSB_CUSTOMIZATIONFILE : OSB customizationFile
###########################################################################################

# Check for input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: ./deployOsb.sh <OSB_FILE> <OSB_CUSTOMIZATIONFILE>"
	echo "OSB not deployed"
	exit -1
fi

echo "## Deploy OSB ##"
. $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
echo "##environment loaded ##"

java weblogic.WLST ./scripts/deployOsb.py ./scripts/serverInfo.properties $1 $2
echo "## OSB deployment finished ##"
