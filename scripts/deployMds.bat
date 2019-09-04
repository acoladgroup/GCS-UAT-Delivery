@REM ###########################################################################################
@REM # Script purpose: Deploy MDS
@REM # Author: Nicolas Goyet - AMPLEXOR
@REM # Change date: 09/2019
@REM # Usage: ./deployMds.bat <MDS_ARCHIVE>
@REM #				MDS_ARCHIVE : MDS archive
@REM ###########################################################################################

@if "%1" == "" (
	@goto :usage
)

@echo "## Start deployment ##"
@call %oracle_home%\wlserver\server\bin\setWLSEnv.cmd
@echo "## Environment loaded ##"

@call .\scripts\setBpmServerConfig.bat

java weblogic.WLST ./scripts/deployMds.py %ADMIN_URL% %ADMIN_LOGIN% %ADMIN_PASSWORD% %1
@echo "## MDS deployment finished ##"

@goto :end

:usage
@echo "Usage: ./deployMds.bat <MDS_ARCHIVE>"
@echo "MDS not deployed"

:end