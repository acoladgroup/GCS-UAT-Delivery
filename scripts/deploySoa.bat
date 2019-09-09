@REM ###########################################################################################
@REM # Script purpose: Deploy SOA
@REM # Author: Nicolas Goyet - AMPLEXOR
@REM # Change date: 09/2019
@REM # Usage: ./deploySoa.sh <SOA_FILE> <SOA_CFGPLAN>
@REM #				SOA_FILE 	: SOA composite
@REM #				SOA_CFGPLAN : SOA configuration plan
@REM ###########################################################################################

@if "%2" == "" (
	@goto :usage
)

@echo "## Start deployment ##"
@call %oracle_home%\wlserver\server\bin\setWLSEnv.cmd
@echo "## Environment loaded ##"

@call .\scripts\setBpmServerConfig.bat

java weblogic.WLST ./scripts/deploySoa.py %SOA_SERVER_URL% %ADMIN_LOGIN% %ADMIN_PASSWORD% %1 %2
@echo "## SOA composite deployment finished ##"

@goto :end

:usage
@echo "Usage: ./deploySoa.bat <SOA_FILE> <SOA_CFGPLAN>"
@echo "SOA composite not deployed"

:end