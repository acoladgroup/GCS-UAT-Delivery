archive = getMDSArchiveConfig(fromLocation=sys.argv[1])
archive.setAppMetadataRepository(repository='mds-gcs', partition='gcsapp', type='DB', jndi='jdbc/mds/gcs')
archive.save()
exit()