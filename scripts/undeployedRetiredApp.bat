@REM ###########################################################################################
@REM # Script purpose: Undeploy a retired application
@REM # Author: Nicolas Goyet - AMPLEXOR
@REM # Change date: 08/2019
@REM # Usage: ./undeployedRetiredVersion.sh <APP_NAME>
@REM #				APP_NAME : Name of the application
@REM ###########################################################################################

# Check for input arguments
@if "%1" == "" (
	@goto :usage
)

@echo "## Undeploy a retired application ##"
@call %oracle_home%\wlserver\server\bin\setWLSEnv.cmd
@echo "##environment loaded ##"

@if "%1" == "PMWS" (
	@call scripts/setBpmServerConfig.bat
) else (
	@call scripts/setAdfServerConfig.bat
)

java weblogic.WLST ./scripts/undeployedRetiredApp.py %ADMIN_URL% %ADMIN_LOGIN% %ADMIN_PASSWORD% %1
@echo "## Undeploy finished ##"

@goto :end

:usage
@echo "Usage: ./undeployedRetiredApp.bat <APP_NAME>"
@echo "Application is not retired"

:end

