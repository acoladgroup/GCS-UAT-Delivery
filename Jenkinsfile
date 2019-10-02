/**
 * Content of Jenkinsfile.properties file
 */
props = null

/**
 * Working folder
 */
workingDirectory = './work'

/**
 * Status of the deployment
 */
fullyDeployed = true

/**
 * Content of delivery.json file
 */
def json

/**
 * Deploy the Spring application
 * @param item Nexus artifact
 */
def deploySpring(item) {
    if (!item.deployed) {
        displayManagementMessage(item)

        try {
            item.downloaded = false
            item.deployed = false

            item.downloaded = downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":war")

            if (!params['Dry run ?']) {
                deployToTomcat(item)

                item.deployed = true
            }

            displaySuccessMessage(item)
        } catch (e) {
            manageCatchedError(item, e)
        } finally {
            dir(workingDirectory) {
                deleteDir()
            }
        }
    } else {
        manageCompositeAlreadyDeployed(item)
    }
}

/**
 * Deploy the Angular application
 * @param item Nexus artifact
 */
def deployAngular(item) {
    if (!item.deployed) {
        displayManagementMessage(item)

        try {
            item.downloaded = false
            item.deployed = false

            item.downloaded = downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":war")

            if (!params['Dry run ?']) {
                deployToTomcat(item)

                copyJsConfigFile(item)

                item.deployed = true
            }

            displaySuccessMessage(item)
        } catch (e) {
            manageCatchedError(item, e)
        } finally {
            dir(workingDirectory) {
                deleteDir()
            }
        }
    } else {
        manageCompositeAlreadyDeployed(item)
    }
}

/**
 * Deploy ADF application
 * @param gcmAppName Name of the application to deploy
 * @param item Nexus artifact
 */
def deployAdfApp(gcmAppName, item) {
    if (!item.deployed) {
        displayManagementMessage(item)

        try {
            item.downloaded = false
            item.deployed = false

            downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":ear")

            // Download and unzip config plan archive. No config plan for PMWS
            if (gcmAppName != 'PMWS') {
                downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":jar:cfgplan")

                unzipConfigplan(item)

                // find config plan file name
                def cfgPlan = findFiles(glob: "**/work/" + props.gcsEnvironment + "/" + gcmAppName + "-plan.xml")

                if (cfgPlan.size() != 1) {
                    throw new Exception("Configuration plan not found for " + item.group + ":" + item.name + ":" + item.version + " for the environment:" + props.gcsEnvironment)
                }
            }

            item.downloaded = true

            if (!params['Dry run ?']) {
                // Handle ORA MDS configuration (only for the GCM application)
                if (gcmAppName == 'GCM') {
                    changeMDSConfiguration(item)
                }

                // Undeploy the previous version
                undeployedRetiredApp(gcmAppName, item)

                // deploy the application
                deployApp(gcmAppName, item)

                item.deployed = true
            }

            displaySuccessMessage(item)
        } catch (e) {
            manageCatchedError(item, e)
        } finally {
            dir(workingDirectory) {
                deleteDir()
            }
        }
    } else {
        manageCompositeAlreadyDeployed(item)
    }
}

/**
 * Deploy the SOA MDS on BPM server
 * @param item item to deploy
 */
def deploySoaMds(item) {
    if (!item.deployed) {
        displayManagementMessage(item)

        try {
            item.downloaded = false
            item.deployed = false

            downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":jar")

            if (!params['Dry run ?']) {
                println("SOAMDS deployment of " + item.group + ":" + item.name + ":" + item.version)

                def stdoutResult = sh(returnStdout: true, script: "./scripts/deployMds.sh " + workingDirectory + "/" + item.name + "-" + item.version + ".jar").trim()

                println("************ Result of SOAMDS deployment  **************")
                println(stdoutResult)
                println("********************************************************")

                if (!stdoutResult.contains("Operation \"importMetadata\" completed")) {
                    item.deployed = false
                    throw new Exception("Can't deploy the SOAMDS " + item.group + ":" + item.name + ":" + item.version)
                }

                item.deployed = true
            }

            displaySuccessMessage(item)
        } catch (e) {
            manageCatchedError(item, e)
        } finally {
            dir(workingDirectory) {
                deleteDir()
            }
        }
    } else {
        manageCompositeAlreadyDeployed(item)
    }
}

/**
 * Deploy the SOA composite
 * @param item item to deploy
 */
def deploySoa(item) {
    if (!item.deployed) {
        displayManagementMessage(item)

        try {
            item.downloaded = false
            item.deployed = false

            downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":jar")
            downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":jar:cfgplan")

            // unzip configuration plan
            unzipConfigplan(item)

            // find config plan file name
            def cfgPlan = findFiles(glob: "**/work/" + props.gcsEnvironment + "/*.xml")

            if (cfgPlan.size() != 1) {
                throw new Exception("Configuration plan not found for " + item.group + ":" + item.name + ":" + item.version + " for the environment:" + props.gcsEnvironment)
            }

            def compositeName = "sca_" + cfgPlan[0].name.substring(0, (cfgPlan[0].name.length() - 12)) + "_rev" + item.version + ".jar"

            // Rename composite file to support the naming convention : https://support.oracle.com/epmos/faces/SearchDocDisplay?_adf.ctrl-state=11q3bv937b_9&_afrLoop=526667531616007#SYMPTOM
            fileOperations([fileRenameOperation(destination: workingDirectory + '/' + compositeName, source: workingDirectory + '/' + item.name + '-' + item.version + '.jar')])

            item.downloaded = true

            if (!params['Dry run ?']) {
                def stdoutResult = sh(returnStdout: true, script: "./scripts/deploySoa.sh " + workingDirectory + "/" + compositeName + " " + workingDirectory + "/" + props.gcsEnvironment + "/" + cfgPlan[0].name).trim()

                println("************   Result of SOA deployment   **************")
                println(stdoutResult)
                println("********************************************************")

                if (!stdoutResult.contains("Deploying composite success")) {
                    item.deployed = false
                    throw new Exception("Can't deploy the SOA " + item.group + ":" + item.name + ":" + item.version)
                }

                item.deployed = true
            }

            displaySuccessMessage(item)
        } catch (e) {
            manageCatchedError(item, e)
        } finally {
            dir(workingDirectory) {
                deleteDir()
            }
        }
    } else {
        manageCompositeAlreadyDeployed(item)
    }
}

/**
 * Deploy the OSB composite
 * @param item item to deploy
 */
def deployOsb(item) {
    if (!item.deployed) {
        displayManagementMessage(item)

        try {
            item.downloaded = false
            item.deployed = false

            downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":sbar")
            downloadArtifact(item.group + ":" + item.name + ":" + item.version + ":jar:cfgplan")

            // unzip configuration plan
            unzipConfigplan(item)

            // find config plan file name
            cfgPlan = findFiles(glob: "**/work/" + props.gcsEnvironment + "/*.xml")

            if (cfgPlan.size() != 1) {
                throw new Exception("Configuration plan not found for " + item.group + ":" + item.name + ":" + item.version + " for the environment:" + props.gcsEnvironment)
            }

            item.downloaded = true

            if (!params['Dry run ?']) {
                def stdoutResult = sh(returnStdout: true, script: "./scripts/deployOsb.sh " + workingDirectory + "/" + item.name + "-" + item.version + ".sbar " + workingDirectory + "/" + props.gcsEnvironment + "/" + cfgPlan[0].name).trim()

                println("************   Result of OSB deployment   **************")
                println(stdoutResult)
                println("********************************************************")

                if (!stdoutResult.contains("Deployment of " + workingDirectory + "/" + item.name + "-" + item.version + ".sbar successful")) {
                    item.deployed = false
                    throw new Exception("Can't deploy the OSB " + item.group + ":" + item.name + ":" + item.version)
                }

                item.deployed = true
            }

            displaySuccessMessage(item)
        } catch (e) {
            manageCatchedError(item, e)
        } finally {
            dir(workingDirectory) {
                deleteDir()
            }
        }
    } else {
        manageCompositeAlreadyDeployed(item)
    }
}

/**
 * Change the MDS configuration of an ADF app
 * @param item
 */
def changeMDSConfiguration(item) {
    println("Change MDS configuration")

    def stdoutResult = sh(returnStdout: true, script: "./scripts/changeMdsConfig.sh " + workingDirectory + "/" + item.name + "-" + item.version + ".ear").trim()

    println("************ Result of change MDS configuration **************")
    println(stdoutResult)
    println("**************************************************************")

    if (!stdoutResult.contains("Operation \"setAppMetadataRepository\" successful")) {
        item.deployed = false
        throw new Exception("Can't change the MDS configuration " + item.group + ":" + item.name + ":" + item.version)
    }
}

/**
 * Undeployed the oldest ADF application
 * @param gcmAppName Name of the application to undeployed
 * @param item item to deploy
 */
def undeployedRetiredApp(gcmAppName, item) {
    println("Undeploy the retired version of " + gcmAppName)

    stdoutResult = sh(returnStdout: true, script: "./scripts/undeployedRetiredApp.sh " + gcmAppName)

    println("********** Result of undeploy the retired version ************")
    println(stdoutResult)
    println("**************************************************************")

    // Uninstall ok if :
    // -- connection OK => contains "Successfully connected"
    // -- no uninstallation needed => doesn't contains "This app is should be uninstalled"
    // -- installation needed and uninstallation completed => contains "This app is should be uninstalled" && contains "Completed the undeployment of Application with status completed"
    if (!(stdoutResult.contains("Successfully connected") && (!stdoutResult.contains("This app is should be uninstalled") || (stdoutResult.contains("This app is should be uninstalled") && stdoutResult.contains("Completed the undeployment of Application with status completed"))))) {
        item.deployed = false
        throw new Exception("Can't uninstall retired version of " + item.group + ":" + item.name + ":" + item.version)
    }
}

/**
 * Download a nexus artifact
 * @param artifactId item to download
 * @return True if the download works
 */
def downloadArtifact(artifactId) {
    println("#####     Download of " + artifactId + "     ######")

    withMaven(mavenSettingsConfig: props.mavenSettingsConfig) {
        sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=" + artifactId + " -DoutputDirectory=" + workingDirectory
    }

    return true
}

/**
 * Deploy item to tomcat server
 * @param item item to deployed
 */
def deployToTomcat(item) {
    displayDeployMessage(item)

    withMaven(mavenSettingsConfig: props.mavenSettingsConfig) {
        sh "mvn tomcat7:deploy-only -Dpath=/" + item.name + " -DwarFile=" + workingDirectory + "/" + item.name + "-" + item.version + ".war"
    }
}

/**
 * Copy the js file to the webapp
 * @param item item
 */
def copyJsConfigFile(item) {
    def stdoutResult

    withCredentials([sshUserPrivateKey(credentialsId: props.tomcatServiceCredentialsId, keyFileVariable: 'keyfile')]) {
        stdoutResult = sh(returnStdout: true, script: "scp -i ${keyfile} -p ./resources/angular/" + props.gcsEnvironment + "/" + item.name + "-config.js tomcat@" + props.tomcatServiceHost + ":" + props.tomcatServiceWebappsFolder + item.name + "/").trim()
    }

    println("#####        Result of SCP " + item.group + ":" + item.name + ":" + item.version + "         ######")
    println(stdoutResult)
    println("########################################################################################################################")

    if (stdoutResult != "") {
        item.deployed = false
        throw new Exception("Can't copy js file for " + item.group + ":" + item.name + ":" + item.version + " on " + props.tomcatServiceHost + ":" + props.tomcatServiceWebappsFolder + item.name + "/")
    }
}

/**
 * Unzip the config plan zip
 * @param item item to unzip
 * @return
 */
def unzipConfigplan(item) {
    try {
        unzip zipFile: workingDirectory + '/' + item.name + '-' + item.version + '-cfgplan.jar', dir: workingDirectory
    } catch (e) {
        println('ERROR : ' + e)
        item.deployed = false
        throw new Exception("Can't unzip config plan " + item.group + ":" + item.name + ":" + item.version)
    }
}

/**
 * Deploy a new ADF application
 * @param gcmAppName Name of the application
 * @param item item to deploy
 */
def deployApp(gcmAppName, item) {
    println("Deployment of " + gcmAppName)

    if (gcmAppName == 'PMWS') {
        stdoutResult = sh(returnStdout: true, script: "./scripts/deployApp.sh " + gcmAppName + " ./work/" + item.name + "-" + item.version + ".ear")
    } else {
        stdoutResult = sh(returnStdout: true, script: "./scripts/deployApp.sh " + gcmAppName + " ./work/" + item.name + "-" + item.version + ".ear ./work/" + props.gcsEnvironment + "/" + gcmAppName + "-plan.xml")
    }

    println("************** Result of deploy the EAR file *****************")
    println(stdoutResult)
    println("**************************************************************")

    if (!(stdoutResult.contains("redeploy completed") || stdoutResult.contains("Unable to contact \"gcm_server2\". Deployment is deferred until \"gcm_server2\""))) {
        item.deployed = false
        throw new Exception("Can't install the new version of " + item.group + ":" + item.name + ":" + item.version)
    }
}

/**
 * Display deployment message
 * @param item item
 */
def displayManagementMessage(item) {
    println("########################################################################################################################")
    println("#                   Management of " + item.group + ":" + item.name + ":" + item.version)
    println("########################################################################################################################")
}

/**
 * Display deployment message
 * @param item item
 */
def displayDeployMessage(item) {
    println("#####     Deployment of " + item.group + ":" + item.name + ":" + item.version + "     ######")
}

/**
 * Display success message
 * @param item item
 */
def displaySuccessMessage(item) {
    item.status = 'OK'

    println("########################################################################################################################")
    println("#         " + item.group + ":" + item.name + ":" + item.version + " has been deployed with success")
    println("########################################################################################################################")
}

/**
 * Mange composite already deployed
 * @param item
 * @return
 */
def manageCompositeAlreadyDeployed (item) {
    item.redeployedStatus = true

    println("################    " + item.group + ":" + item.name + ":" + item.version + " is already deployed     ################")
}

def manageCatchedError (item, error) {
    fullyDeployed = false

    println('ERROR : ' + error)
    println("########################################################################################################################")
    println("          An error occurs during the deployment of " + item.group + ":" + item.name + ":" + item.version)
    println("########################################################################################################################")

    if (item.downloaded) {
        item.status = "IN ERROR: Can't deployed the artefact " + item.group + ":" + item.name + ":" + item.version
    } else {
        item.status = "IN ERROR: Can't download the artefact " + item.group + ":" + item.name + ":" + item.version
    }
}

/**
 * check if the properties exists
 * @param props Array of values
 * @param propertyName Name of the property
 */
def checkProperties(props, propertyName) {
    if (props == null || props[propertyName] == null) {
        println("ERROR Property + " + propertyName + " not found")
        throw new Exception("Property + " + propertyName + " not found")
    }
}
/**
 * Build the HTML report
 * @param items list of items deployed
 */
def buildHTMLReport(items) {
    def html = '<html>'
    html += '<head>'
    html += '<link href="assets/css/bootstrap.min.css" rel="stylesheet"/>'
    html += '</head>'
    html += '<body>'
    html += '<div class="container-fluid">'
    html += '<h1 class="text-center">Deployment of the release from ' + env.BRANCH_NAME + '</h1>'
    html += '<br/><br/>'

    // Display parameters
    html += '<fieldset>'
    html += '<legend>Job parameters</legend>'
    html += '<p><b>Dry run : </b>' + params['Dry run ?'] + '</p>'
    html += '</fieldset><hr/>'

    // Display GCM_app deployment result
    html += '<fieldset>'
    html += '<legend>GCM app</legend>'

    if (items.delivery.adf_app != null && items.delivery.adf_app.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.adf_app);
    }
    html+='</fieldset><hr/>'

    // Display GCSAccouts deployment result
    html += '<fieldset>'
    html += '<legend>GCSAccounts app</legend>'

    if (items.delivery.adf_accounts != null && items.delivery.adf_accounts.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.adf_accounts);
    }
    html+='</fieldset><hr/>'

    // Display DMWS deployment result
    html += '<fieldset>'
    html += '<legend>DMWS app</legend>'

    if (items.delivery.adf_dmws != null && items.delivery.adf_dmws.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.adf_dmws);
    }
    html+='</fieldset><hr/>'

    // Display DMRESTWS deployment result
    html += '<fieldset>'
    html += '<legend>DMRESTWS app</legend>'

    if (items.delivery.adf_dmrestws != null && items.delivery.adf_dmrestws.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.adf_dmrestws);
    }
    html+='</fieldset><hr/>'

    // Display PMWS deployment result
    html += '<fieldset>'
    html += '<legend>PMWS app</legend>'

    if (items.delivery.adf_pmws != null && items.delivery.adf_pmws.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.adf_pmws);
    }
    html+='</fieldset><hr/>'

    // Display MDS deployment result
    html += '<fieldset>'
    html += '<legend>SOA MDS</legend>'

    if (items.delivery.soa_mds != null && items.delivery.soa_mds.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.soa_mds);
    }
    html+='</fieldset><hr/>'

    // Display SOA deployment result
    html += '<fieldset>'
    html += '<legend>SOA</legend>'

    if (items.delivery.soa != null && items.delivery.soa.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.soa);
    }
    html+='</fieldset><hr/>'

    // Display OSB deployment result
    html += '<fieldset>'
    html += '<legend>OSB</legend>'

    if (items.delivery.osb != null && items.delivery.osb.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.osb);
    }
    html+='</fieldset><hr/>'

    // Display Spring services deployment result
    html += '<fieldset>'
    html += '<legend>Spring services</legend>'

    if (items.delivery.spring != null && items.delivery.spring.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.spring);
    }
    html+='</fieldset><hr/>'

    // Display Angular services deployment result
    html += '<fieldset>'
    html += '<legend>Angular services</legend>'

    if (items.delivery.angular != null && items.delivery.angular.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.angular);
    }
    html+='</fieldset><hr/>'

    html+='</body>'
    html += '</html>'

    writeFile file: "report.html", text: html, encoding: "UTF-8"
}

/**
 * Build a table from a list of items
 * @param listOfItems list of items
 * @return html code
 */
def buildTable(listOfItems) {
    def html = '<table class="table table-striped">'
    html+='<tr class="row">'
    html+='<th class="col-md-2">GroupId</th>'
    html+='<th class="col-md-2">ArtefactId</th>'
    html+='<th class="col-md-2">Version</th>'
    html+='<th class="col-md-2">Is downloaded</th>'
    html+='<th class="col-md-2">Is deployed</th>'
    html+='<th class="col-md-2">Status</th>'
    html+='</tr>'
    listOfItems.each{
        html += '<tr class="row">'
        html += '<td class="col-md-2">' + it.group + '</td>'
        html += '<td class="col-md-2">' + it.name + '</td>'
        html += '<td class="col-md-2">' + it.version + '</td>'

        if (it.redeployedStatus) {
            html += '<td class="col-md-2"></td>'
            html += '<td class="col-md-2"></td>'
            html += '<td class="col-md-2">Not deployed, the component is already deployed</td>'
        } else {
            html += '<td class="col-md-2">' + it.downloaded + '</td>'
            html += '<td class="col-md-2">' + it.deployed + '</td>'
            html += '<td class="col-md-2">' + it.status + '</td>'
        }

        html += '</tr>'
    }
    html+='</table>'

    return html
}


pipeline {
    agent  { node { label 'alt' } }
    parameters {
        booleanParam(name: "Dry run ?", description: "Be careful, if you check this option the composite will be deployed", defaultValue: true)
    }
    environment {
        JAVA_HOME = "/usr/lib/jvm/java-8-oracle"
      	ORACLE_HOME = "/home/jenkins/oracle/12.2.1.3/mw/bpm"
    }
    stages {
        stage('Prepare scripts') {
            steps {
                script {
                    sh "chmod +x ./scripts/*.sh"
                }
            }
        }
        stage('Read Jenkinsfile properties') {
            steps {
                script {
                    props = readProperties file: 'Jenkinsfile.properties'

                    checkProperties(props, 'gcsEnvironment')
                    checkProperties(props, 'mavenSettingsConfig')
                    checkProperties(props, 'gitCredentialsId')
                    checkProperties(props, 'tomcatServiceCredentialsId')
                    checkProperties(props, 'tomcatServiceHost')
                    checkProperties(props, 'tomcatServiceWebappsFolder')

                    println("########################################################################################################################")
                    println("#                   Deployment on " + props.gcsEnvironment + " environment")
                    println("########################################################################################################################")
                }
            }
        }
        stage('Read delivery file') {
            steps {
                script {
                    json = readJSON file: 'delivery.json'
                }
            }
        }
        stage('Deploy GCM APP') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.adf_app != null && json.delivery.adf_app.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.adf_app) {
                        deployAdfApp('GCM', item)
                    }
                }
            }
        }
        stage('Deploy GCSAccounts') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.adf_accounts != null && json.delivery.adf_accounts.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.adf_accounts) {
                        deployAdfApp('GCSAccounts', item)
                    }
                }
            }
        }
        stage('Deploy DMWS') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.adf_dmws != null && json.delivery.adf_dmws.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.adf_dmws) {
                        deployAdfApp('DMWS', item)
                    }
                }
            }
        }
        stage('Deploy DMRESTWS') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.adf_dmrestws != null && json.delivery.adf_dmrestws.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.adf_dmrestws) {
                        deployAdfApp('DMRESTWS', item)
                    }
                }
            }
        }
        stage('Deploy PMWS') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.adf_pmws != null && json.delivery.adf_pmws.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.adf_pmws) {
                        deployAdfApp('PMWS', item)
                    }
                }
            }
        }
        stage('Deploy SOA MDS') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.soa_mds != null && json.delivery.soa_mds.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.soa_mds) {
                        deploySoaMds(item)
                    }
                }
            }
        }
        stage('Deploy SOA') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.soa != null && json.delivery.soa.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.soa) {
                        deploySoa(item)
                    }
                }
            }
        }
        stage('Deploy OSB') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.osb != null && json.delivery.osb.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.osb) {
                        deployOsb(item)
                    }
                }
            }
        }
        stage('Deploy Spring component') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.spring != null && json.delivery.spring.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.spring) {
                        deploySpring(item)
                    }
                }
            }
        }
        stage('Deploy Angular component') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && json.delivery.angular != null && json.delivery.angular.size() != 0} }
            steps {
                script {
                    for (String item : json.delivery.angular) {
                        deployAngular(item)
                    }
                }
            }
        }
        stage('Check installation') {
            steps {
                script {
                    if (!fullyDeployed) {
                        throw new Exception("At least one component installation failed. Please check the log")
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                // Lock the delivery file to avoid a second execution
                if (!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && !params['Dry run ?']) {
                    sh "rm -rf delivery.json"

                    json.delivery.deployed = fullyDeployed

                    writeJSON json: json, file: 'delivery.json', pretty: 2
                    def git_configured_url = sh(returnStdout: true, script: 'git config remote.origin.url').trim()

                    withCredentials([usernamePassword(credentialsId: props.gitCredentialsId, passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        sh "git add delivery.json"
                        sh 'git commit -m "locking of this version"'
                        repository = git_configured_url.replace("https://", "")
                        sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@' + repository)
                    }
                }

                buildHTMLReport(json)
                publishHTML(target: [
                        allowMissing         : false,
                        alwaysLinkToLastBuild: false,
                        keepAll              : true,
                        reportDir            : '.',
                        reportFiles          : 'report.html',
                        reportName           : "Deployment report"
                ])
            }
        }
    }
}
