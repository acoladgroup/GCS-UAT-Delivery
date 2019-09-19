import wlstModule
from com.bea.wli.sb.management.configuration import SessionManagementMBean
from com.bea.wli.sb.management.configuration import ALSBConfigurationMBean
from com.bea.wli.config import Ref
from com.bea.wli.sb.util import Refs

from java.util import HashMap
from java.util import HashSet
from java.util import ArrayList
from java.io import FileInputStream
from java.util import Collections
from com.bea.wli.config.resource import Diagnostic
from com.bea.wli.sb.util import EnvValueTypes
from com.bea.wli.config.env import QualifiedEnvValue
from com.bea.wli.config.env import EnvValueQuery
from com.bea.wli.config.customization import EnvValueCustomization


from com.bea.wli.config.customization import Customization
from com.bea.wli.sb.management.importexport import ALSBImportOperation

import sys

#=======================================================================================
# Entry function to deploy project configuration and resources
# into a ALSB domain
#=======================================================================================

def deployOsb(serverInfoFile, osbSbar, osbCustomizationFile):
	try:
		SessionMBean = None
		print 'Loading Deployment config from :', serverInfoFile
		exportConfigProp = loadProps(serverInfoFile)
		
		adminUrl = exportConfigProp.get("osbAdminUrl")
		adminUser = exportConfigProp.get("osbAdminUser")
		adminPassword = exportConfigProp.get("osbAdminPassword")
		
		connectToServer(adminUser, adminPassword, adminUrl)

		print 'Deployment of  :', osbSbar, "on Admin Server listening on :", adminUrl

		theBytes = readBinaryFile(osbSbar)
		print 'Read file', osbSbar
		
		sessionName = createSessionName()
		print 'Created session', sessionName
		
		SessionMBean = getSessionManagementMBean(sessionName)
		print 'SessionMBean started session'
		
		ALSBConfigurationMBean = findService(String("ALSBConfiguration.").concat(sessionName), "com.bea.wli.sb.management.configuration.ALSBConfigurationMBean")
		print "ALSBConfiguration MBean found", ALSBConfigurationMBean
		
		ALSBConfigurationMBean.uploadJarFile(theBytes)
		print 'Jar Uploaded'

		print 'Deployment of ', osbSbar
		alsbJarInfo = ALSBConfigurationMBean.getImportJarInfo()
		alsbImportPlan = alsbJarInfo.getDefaultImportPlan()
		operationMap=HashMap()
		operationMap = alsbImportPlan.getOperations()
		print
		print 'Default importPlan'
		printOpMap(operationMap)
		set = operationMap.entrySet()

		alsbImportPlan.setPreserveExistingEnvValues(true)

		#boolean
		abort = false
		#list of created ref
		createdRef = ArrayList()
		
		for entry in set:
			ref = entry.getKey()
			op = entry.getValue()
			#set different logic based on the resource type
			type = ref.getTypeId
			if type == Refs.SERVICE_ACCOUNT_TYPE or type == Refs.SERVICE_PROVIDER_TYPE:
				if op.getOperation() == ALSBImportOperation.Operation.Create:
					print 'Unable to import a service account or a service provider on a target system', ref
					abort = true
			else:
				createdRef.add(ref)
				
		if abort == true :
			print 'This jar must be imported manually to resolve the service account and service provider dependencies'
			SessionMBean.discardSession(sessionName)
			raise

		print
		print 'Modified importPlan'

		importResult = ALSBConfigurationMBean.importUploaded(alsbImportPlan)

		printDiagMap(importResult.getImportDiagnostics())

		if importResult.getFailed().isEmpty() == false:
			print 'One or more resources could not be imported properly'
			raise

		#customize if a customization file is specified
		if osbCustomizationFile != None :
			print 'Loading customization File', osbCustomizationFile
			print 'Customization applied to the following resources ', createdRef
			iStream = FileInputStream(osbCustomizationFile)
			customizationList = Customization.fromXML(iStream)
			filteredCustomizationList = ArrayList()
			setRef = HashSet(createdRef)

			# apply a filter to all the customizations to narrow the target to the created resources
			for customization in customizationList:
				print customization
				newcustomization = customization.clone(setRef)
				filteredCustomizationList.add(newcustomization)

			ALSBConfigurationMBean.customize(filteredCustomizationList)

		SessionMBean.activateSession(sessionName, "Complete import of " + osbSbar + "with customization using wlst")

		print "Deployment of " + osbSbar + " successful"
	except:
		print "Unexpected error:", sys.exc_info()[0]
		if SessionMBean != None:
			SessionMBean.discardSession(sessionName)
		raise

#=======================================================================================
# Utility function to print the list of operations
#=======================================================================================
def printOpMap(map):
	set = map.entrySet()
	for entry in set:
		op = entry.getValue()
		print op.getOperation(),
		ref = entry.getKey()
		print ref
	print

#=======================================================================================
# Utility function to print the diagnostics
#=======================================================================================
def printDiagMap(map):
	set = map.entrySet()
	for entry in set:
		diag = entry.getValue().toString()
		print diag
	print

#=======================================================================================
# Utility function to load properties from a config file
#=======================================================================================

def loadProps(configPropFile):
	propInputStream = FileInputStream(configPropFile)
	configProps = Properties()
	configProps.load(propInputStream)
	return configProps

#=======================================================================================
# Connect to the Admin Server
#=======================================================================================

def connectToServer(username, password, url):
	connect(username, password, url)
	domainRuntime()

#=======================================================================================
# Utility function to read a binary file
#=======================================================================================
def readBinaryFile(fileName):
	file = open(fileName, 'rb')
	bytes = file.read()
	return bytes

#=======================================================================================
# Utility function to create an arbitrary session name
#=======================================================================================
def createSessionName():
	sessionName = String("SessionScript"+Long(System.currentTimeMillis()).toString())
	return sessionName

#=======================================================================================
# Utility function to load a session MBeans
#=======================================================================================
def getSessionManagementMBean(sessionName):
	SessionMBean = findService("SessionManagement", "com.bea.wli.sb.management.configuration.SessionManagementMBean")
	SessionMBean.createSession(sessionName)
	return SessionMBean

# IMPORT script init
try:
	# import the service bus configuration
	# argv[1] is the export config properties file
	deployOsb(sys.argv[1], sys.argv[2], sys.argv[3])

except:
	print "Unexpected error: ", sys.exc_info()[0]
	dumpStack()
	raise