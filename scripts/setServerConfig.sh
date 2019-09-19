#!/bin/bash
###########################################################################################
# Script purpose: Set TEST variables
# Author: Nicolas Goyet - AMPLEXOR
# Change date: 08/2019
# Usage: ./setServerConfig.sh
###########################################################################################

# Properties for APP server
export APP_ADMIN_URL="t3://xi02uu-gcm-app1.amplexor.com:7002"
export APP_ADMIN_LOGIN="weblogic"
export APP_ADMIN_PASSWORD="ict4gcmuat"
export APP_TARGET="gcm_cluster"

# Properties for BPM server
export BPM_ADMIN_URL="t3://xi02uu-gcm-bpm1.amplexor.com:7002"
export BPM_ADMIN_LOGIN="weblogic"
export BPM_ADMIN_PASSWORD="ict4gcmuat"
export BPM_TARGET="soa_cluster"
export BPM_SOA_SERVER_URL="http://xi02uu-gcm-bpm1.amplexor.com:8001"
