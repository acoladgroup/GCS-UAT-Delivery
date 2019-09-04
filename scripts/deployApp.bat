@REM ###########################################################################################
@REM # Script purpose: Deploy a new version of an Application
@REM # Author: Nicolas Goyet - AMPLEXOR
@REM # Change date: 08/2019
@REM # Usage: ./deployAdfAppOnAdfServer.bat <APP_NAME> <EAR_FILE> <CONFIG_PLAN>
@REM #				APP_NAME 		: Application name
@REM #				EAR_FILE 		: File to deploy
@REM #				CONFIG_PLAN 	: Config plan to use
@REM ###########################################################################################

@if "%3" == "" (
	@goto :usage
)

@echo "## Start deployment ##"
@call %oracle_home%\wlserver\server\bin\setWLSEnv.cmd
@echo "## Environment loaded ##"

if "%1" == "PMWS" (
	@call .\scripts\setBpmServerConfig.bat
) else (
	@call .\scripts\setAdfServerConfig.bat
)
	
if "%1" == "PMWS" (
	java -classpath %oracle_home%/wlserver/server/lib/weblogic.jar weblogic.Deployer -adminurl %ADMIN_URL% -user %ADMIN_LOGIN% -password %ADMIN_PASSWORD% -targets %TARGET% -name %1 -source %2 -upload -redeploy
) else (
	java -classpath %oracle_home%/wlserver/server/lib/weblogic.jar weblogic.Deployer -adminurl %ADMIN_URL% -user %ADMIN_LOGIN% -password %ADMIN_PASSWORD% -targets %TARGET% -name %1 -source %2 -plan %3 -upload -redeploy
)

@echo "## End deployment ##"

@goto :end

:usage
@echo "Usage: ./deployAdfAppOnAdfServer.bat <APP_NAME> <EAR_FILE> <CONFIG_PLAN>"
@echo "EAR file not deployed"

:end
