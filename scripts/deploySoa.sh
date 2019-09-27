#!/bin/bash
###########################################################################################
# Script purpose: Deploy SOA
# Author: Nicolas Goyet - AMPLEXOR
# Change date: 09/2019
# Usage: ./deploySoa.sh <SOA_FILE> <SOA_CFGPLAN>
#				SOA_FILE 	: SOA composite
#				SOA_CFGPLAN : SOA configuration plan
###########################################################################################

# Check for input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: ./deploySoa.sh <SOA_FILE> <SOA_CFGPLAN>"
	echo "SOA composite not deployed"
	exit -1
fi

echo "## Deploy SOA composite ##"
. $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
echo "##environment loaded ##"

java weblogic.WLST ./scripts/deploySoa.py ./scripts/serverInfo.properties $1 $2
echo "## SOA composite deployment finished ##"
