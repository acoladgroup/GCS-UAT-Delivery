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

echo "## Deploy a retired application ##"
. $ORACLE_HOME/wlserver/server/bin/setWLSEnv.sh
echo "##environment loaded ##"

. ./scripts/setBpmServerConfig.sh

java weblogic.WLST ./scripts/deploySoa.py $SOA_SERVER_URL $ADMIN_LOGIN $ADMIN_PASSWORD $1 $2
echo "## SOA composite deployment finished ##"
