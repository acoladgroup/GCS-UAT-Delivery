#=======================================================================================
# Deploy a SOA compsite
#=======================================================================================

def deploySoa(serverInfoFile, soaComposite, soaConfigPlan):
    try:
        print 'Loading Deployment config from :', serverInfoFile
        loadProperties(serverInfoFile)

        sca_deployComposite(SOA_BPM_URL, soaComposite, user=SOA_BPM_LOGIN, password=SOA_BPM_PASSWORD, forceDefault=true, overwrite=false, configplan=soaConfigPlan)
    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise

# IMPORT script init
try:
    # import the soa composite
    # argv[1] is the config properties file
    # argv[2] is the soa composite file
    # argv[3] is the soa config plan file
    deploySoa(sys.argv[1], sys.argv[2], sys.argv[3])

except:
    print "Unexpected error: ", sys.exc_info()[0]
    dumpStack()
    raise

