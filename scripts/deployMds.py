#=======================================================================================
# Import SOAMDS configuration
#=======================================================================================

def importSoaMds(serverInfoFile, soaMds):
    try:
        print 'Loading Deployment config from :', serverInfoFile
        loadProperties(serverInfoFile)

        connect(SOA_BPM_LOGIN, SOA_BPM_PASSWORD, MDS_BPM_URL)

        print 'Deployment of: ', soaMds, " on Admin Server listening on: ", MDS_BPM_URL

        cd('FileStores/mds-soa')
        importMetadata('soa-infra' , 'soa_server1', soaMds, None, None, false, false, false, false, true, None, true)
    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise

# Script start point
try:
    # import the SOA MDS configuration
    # argv[1] is the export config properties file
    # argv[2] is the name of the file to deploy
    importSoaMds(sys.argv[1], sys.argv[2])

except:
    print "Unexpected error: ", sys.exc_info()[0]
    dumpStack()
    raise