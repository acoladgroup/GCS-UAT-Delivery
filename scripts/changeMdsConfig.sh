#!/bin/bash
###########################################################################################
# Script purpose: Switch MDS mode to DB
# Author: Nicolas Goyet - AMPLEXOR
# Change date: 08/2019
# Usage: ./changeMdsConfig.sh <EAR_FILE>
#				EAR_FILE : File to change MDS configuration
###########################################################################################

# Check for input arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: ./changeMdsConfig.sh <EAR_FILE>"
	echo "EAR file not updated"
	exit -1
fi

echo "## Update the MDS configuration ##"

. $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
echo "##environment loaded ##"

java weblogic.WLST ./scripts/changeMdsConfig.py $1
echo "## Update finished ##"