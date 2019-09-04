@REM ###########################################################################################
@REM # Script purpose: Switch MDS mode to DB
@REM # Author: Nicolas Goyet - AMPLEXOR
@REM # Change date: 08/2019
@REM # Usage: ./changeMdsConfig.sh <EAR_FILE>
@REM #				EAR_FILE : File to change MDS configuration
@REM ###########################################################################################

@if "%1" == "" (
	@goto :usage
)

@echo "## Update the MDS configuration ##"

@call %oracle_home%\wlserver\server\bin\setWLSEnv.cmd
@echo "##environment loaded ##"

java weblogic.WLST ./scripts/changeMdsConfig.py %1
@echo "## Update finished ##"

@goto :end

:usage
@echo "Usage: ./changeMdsConfig.sh <EAR_FILE>"
@echo "EAR file not updated"

:end