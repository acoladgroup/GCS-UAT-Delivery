#=======================================================================================
# Undeploy the retired version of the application
#=======================================================================================

def undeployedRetiredVersion(serverInfoFile, appToUndeploy):
	try:
		print 'Loading Deployment config from :', serverInfoFile

		loadProperties(serverInfoFile)

		if appToUndeploy == 'PMWS':
			connect(ADF_BPM_LOGIN, ADF_BPM_PASSWORD, ADF_BPM_URL)
			print 'Check if ' +  appToUndeploy + " should be uninstalled from :", ADF_BPM_URL
		else:
			connect(ADF_APP_LOGIN, ADF_APP_PASSWORD, ADF_APP_URL)
			print 'Check if ' +  appToUndeploy + " should be uninstalled from :", ADF_APP_URL
		
		cd('AppDeployments')
		appList = ls(returnMap='true')

		domainConfig()

		for appName in appList:
			if appName.startswith(appToUndeploy + '#'):
				domainConfig()
				cd ('/AppDeployments/' + appName + '/Targets')
				
				mytargets = ls(returnMap='true')
				domainRuntime()
				cd('AppRuntimeStateRuntime/AppRuntimeStateRuntime')

				for targetinst in mytargets:
					currentAppStatus=cmo.getCurrentState(appName,targetinst)
					print '=============================================================='
					print '||' + appName + '||' + targetinst + '||' + currentAppStatus
					print '============================================================== \n'
					
					if currentAppStatus != 'STATE_ACTIVE':
						print "This app is should be uninstalled \n"
						undeploy(appName,targetinst)
					else:
						print "This app is the current version. Nothing to do \n"
	except:
		print "Unexpected error:", sys.exc_info()[0]
		raise

# Script start point
try:
	# import the service bus configuration
	# argv[1] is the export config properties file
	# argv[2] is the name of the application to undeployed
	undeployedRetiredVersion(sys.argv[1], sys.argv[2])

except:
	print "Unexpected error: ", sys.exc_info()[0]
	dumpStack()
	raise
