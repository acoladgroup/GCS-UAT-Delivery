def undeploy_app(appName,targeinst):
	print "Undeploying " + appName
	undeploy(appName,targetinst)

connect(sys.argv[2],sys.argv[3],url=sys.argv[1])
cd('AppDeployments')
appList = ls(returnMap='true')
print appList
for appName in appList:
	if appName.startswith(sys.argv[4] + '#'):
		pwd()
		domainConfig()
		cd ('/AppDeployments/'+appName+'/Targets')
		mytargets = ls(returnMap='true')
		domainRuntime()
		cd('AppRuntimeStateRuntime')
		cd('AppRuntimeStateRuntime')
		for targetinst in mytargets:
			currentAppStatus=cmo.getCurrentState(appName,targetinst)
			print '=============================================================='
			print '||' + appName
			print '||' + targetinst
			print '||' + currentAppStatus
			print '============================================================== \n'
			if currentAppStatus != 'STATE_ACTIVE':
				print "This app is should be uninstalled \n"
				undeploy_app(appName,targetinst)
			else:
				print "This app is the current version. Nothing to do \n"
