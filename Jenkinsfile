workingDirectory = './work'
gcsEnvironment = 'UAT'

def json
def fullyDeployed = true

/**
 * Deploy the Spring application
 * @param item Nexus artifact
 */
def deploySpring(item) {
    println ("Item : " + item)

    if (!item.deployed) {
        try {
            println("Download of " + item.group + ":" + item.name + ":" + item.version)
            try {
                sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=" + item.group + ":" + item.name + ":" + item.version + ":war -DoutputDirectory=" + workingDirectory

                item.downloaded = true
            } catch (e) {
                println('ERROR : ' + e)
                item.downloaded = false
                item.deployed = false
                throw new Exception("Can't find the artefact " + item.group + ":" + item.name + ":" + item.version)
            }

            if (!params['Dry run ?']) {
                println("Deployment of " + item.group + ":" + item.name + ":" + item.version)
                try {
                    //sh "mvn tomcat7:deploy-only -Dpath=/" + item.name + " -DwarFile=" + workingDirectory + "/" + item.name + "-" + item.version + ".war"
                    item.deployed = true
                } catch (e) {
                    println('ERROR : ' + e)
                    item.deployed = false
                    throw new Exception("Can't deployed the artefact " + item.group + ":" + item.name + ":" + item.version)
                }
            } else {
                item.deployed = false
            }

            item.status = 'OK'
        } catch (e) {
            fullyDeployed = false
            item.status = 'IN ERROR : ' + e
        } finally {
            dir(workingDirectory) {
                deleteDir()
            }
        }
    } else {
        println ("Component already deployed. Nothing to do")
        item.redeployedStatus = true
    }
}

/**
 * Deploy ADF application
 * @param gcmAppName Name of the application to deploy
 * @param item Nexus artifact
 */
def deployAdfApp(gcmAppName, item) {
    println ("Deployment of the artifact : " + item.group + ":" + item.name + ":" + item.version)

    try {
        println("Download of " + item.group + ":" + item.name + ":" + item.version)
        try {
            sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=" + item.group + ":" + item.name + ":" + item.version + ":ear -DoutputDirectory=" + workingDirectory

            if (gcmAppName != 'PMWS') {
                sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=" + item.group + ":" + item.name + ":" + item.version + ":jar:cfgplan -DoutputDirectory=" + workingDirectory
            }

            item.downloaded = true
        } catch (e) {
            println('ERROR : ' + e)
            item.downloaded = false
            item.deployed = false
            throw new Exception("Can't find the artefact " + item.group + ":" + item.name + ":" + item.version)
        }

        if (!params['Dry run ?']) {
            println("Deployment of " + item.group + ":" + item.name + ":" + item.version)

            // Handle ORA MDS configuration (only for the GCM application)
            if (gcmAppName == 'GCM') {
                changeMDSConfiguration(item)
            }

            // Undeploy the previous version
            undeployedRetiredApp(gcmAppName, item)

            // Unzip config plan archive. No config plan for PMWS
            if (gcmAppName != 'PMWS') {
                unzipConfigplan(item)
            }

            // deploy the application
            deployApp(gcmAppName, item)

            item.deployed = true
        } else {
            item.deployed = false
        }

        item.status = 'OK'
    } catch (e) {
        fullyDeployed = false
        item.status = 'IN ERROR : ' + e
    } finally {
        dir(workingDirectory) {
            deleteDir()
        }
    }
}

def deploySoaMds(item) {
    println ("Deployment of the artifact : " + item.group + ":" + item.name + ":" + item.version)

    try {
        println("Download of " + item.group + ":" + item.name + ":" + item.version)
        try {
            sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=" + item.group + ":" + item.name + ":" + item.version + ":jar -DoutputDirectory=" + workingDirectory
            item.downloaded = true
        } catch (e) {
            println('ERROR : ' + e)
            item.downloaded = false
            item.deployed = false
            throw new Exception("Can't find the artefact " + item.group + ":" + item.name + ":" + item.version)
        }

        if (!params['Dry run ?']) {
            println("Deployment of " + item.group + ":" + item.name + ":" + item.version)

            def stdoutResult = sh(returnStdout: true, script: "./scripts/deployMds.sh " + workingDirectory + "/" + item.name + "-" + item.version + ".jar").trim()

            println("************ Result of SOAMDS deployment  **************")
            println(stdoutResult)
            println("**************************************************************")

            if (!stdoutResult.contains("Operation \"importMetadata\" completed")) {
                item.deployed = false
                throw new Exception("Can't deploy the SOAMDS " + item.group + ":" + item.name + ":" + item.version)
            }

            item.deployed = true
        } else {
            item.deployed = false
        }

        item.status = 'OK'
    } catch (e) {
        fullyDeployed = false
        item.status = 'IN ERROR : ' + e
    } finally {
        dir(workingDirectory) {
            // deleteDir()
        }
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
 * Unzip the config plan zip
 * @param item item to unzip
 * @return
 */
def unzipConfigplan(item) {
    println("Unzip config plan")

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
    println("Deploy of " + gcmAppName)

    stdoutResult = sh(returnStdout: true, script: "./scripts/deployApp.sh " + gcmAppName + " ./work/" + item.name + "-" + item.version + ".ear ./work/" + gcsEnvironment + "/" + gcmAppName + "-plan.xml")

    println("************** Result of deploy the EAR file *****************")
    println(stdoutResult)
    println("**************************************************************")

    if (!(stdoutResult.contains("redeploy completed") || stdoutResult.contains("Unable to contact \"gcm_server2\". Deployment is deferred until \"gcm_server2\""))) {
        item.deployed = false
        throw new Exception("Can't install the new version of " + item.group + ":" + item.name + ":" + item.version)
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

    // Display Spring services deployment result
    html += '<fieldset>'
    html += '<legend>Spring services</legend>'

    if (items.delivery.spring != null && items.delivery.spring.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(items.delivery.spring);
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
        booleanParam(name: "Dry run ?", description: 'Be carefull, you will deploy this version on TEST environment', defaultValue: true)
    }
    environment {
        JAVA_HOME = "/usr/lib/jvm/java-8-oracle"
    }
    stages {
        stage('Read delivery file') {
            steps {
                script {
                    json = readJSON file: 'delivery.json'
                }
            }
        }
        stage('Deploy GCM APP') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release')} }
            steps {
                script {
                    for (String item : json.delivery.adf_app) {
                        if (!item.deployed) {
                            deployAdfApp('GCM', item)
                        } else {
                            println ("Component already deployed. Nothing to do")
                            item.redeployedStatus = true
                        }
                    }
                }
            }
        }
        stage('Deploy GCSAccounts') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release')} }
            steps {
                script {
                    for (String item : json.delivery.adf_accounts) {
                        if (!item.deployed) {
                            deployAdfApp('GCSAccounts', item)
                        } else {
                            println ("Component already deployed. Nothing to do")
                            item.redeployedStatus = true
                        }
                    }
                }
            }
        }
        stage('Deploy DMWS') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release')} }
            steps {
                script {
                    for (String item : json.delivery.adf_dmws) {
                        if (!item.deployed) {
                            deployAdfApp('DMWS', item)
                        } else {
                            println ("Component already deployed. Nothing to do")
                            item.redeployedStatus = true
                        }
                    }
                }
            }
        }
        stage('Deploy DMRESTWS') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release')} }
            steps {
                script {
                    for (String item : json.delivery.adf_dmrestws) {
                        if (!item.deployed) {
                            deployAdfApp('DMRESTWS', item)
                        } else {
                            println ("Component already deployed. Nothing to do")
                            item.redeployedStatus = true
                        }
                    }
                }
            }
        }
        stage('Deploy PMWS') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release')} }
            steps {
                script {
                    for (String item : json.delivery.adf_pmws) {
                        if (!item.deployed) {
                            deployAdfApp('PMWS', item)
                        } else {
                            println ("Component already deployed. Nothing to do")
                            item.redeployedStatus = true
                        }
                    }
                }
            }
        }
        stage('Deploy SOA MDS') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release')} }
            steps {
                script {
                    for (String item : json.delivery.soa_mds) {
                        if (!item.deployed) {
                            deploySoaMds(item)
                        } else {
                            println ("Component already deployed. Nothing to do")
                            item.redeployedStatus = true
                        }
                    }
                }
            }
        }
        stage('Deploy Spring component') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release')} }
            steps {
                script {
                    for (String item : json.delivery.spring) {
                        deploySpring(item)
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                // Lock the delivery file to avoid a second execution
                if (!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && !params['Dry run ?']) {
                    sh "rm -rf delivery.json"

                    json.delivery.deployed = fullyDeployed

                    writeJSON json: json, file: 'delivery.json', pretty: 2
                  	def git_configured_url = sh(returnStdout: true, script: 'git config remote.origin.url').trim()
				
					withCredentials([usernamePassword(credentialsId: '45ba18de-ccb8-43fd-a84c-d9ac1f02a2f9', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
						sh "git add delivery.json"
                    	sh 'git commit -m "locking of this version"'
                      	repository = git_configured_url.replace("https://", "")
                      	sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@' + repository)                      
					}
                }
            }
        }
        always {
            script {
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
