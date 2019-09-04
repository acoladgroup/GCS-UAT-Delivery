connect(sys.argv[2],sys.argv[3],url=sys.argv[1])

cd('FileStores/mds-soa')
importMetadata('soa-infra' , 'soa_server1', sys.argv[4], None, None, false, false, false, false, true, None, true)