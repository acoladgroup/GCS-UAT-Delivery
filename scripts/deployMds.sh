#!/bin/bash
###########################################################################################
# Script purpose: Deploy MDS
# Author: Nicolas Goyet - AMPLEXOR
# Change date: 09/2019
# Usage: ./deployMds.sh <MDS_ARCHIVE>
#				MDS_ARCHIVE : MDS archive
###########################################################################################

# Check for input arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: ./deployMds.sh <MDS_ARCHIVE>"
	echo "MDS archive not deployed"
	exit -1
fi

echo "## Deploy a retired application ##"
. $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
echo "##environment loaded ##"

java weblogic.WLST ./scripts/deployMds.py ./scripts/serverInfo.properties $1
echo "## MDS deployment finished ##"
