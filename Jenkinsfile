def json
def jsonForReporting

/**
 * Build the HTML report
 * @param descriptor list of items deployed
 */
def buildHTMLReport(descriptor) {
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

    // Display Spring services deployment result
    html += '<fieldset>'
    html += '<legend>Spring services</legend>'

    if (descriptor.delivery.spring.size() == 0){
        html += '<span>No artifacts found for this version</span>'
    } else {
        html += buildTable(descriptor.delivery.spring);
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
        html+='<tr class="row">'
        html+='<td class="col-md-2">' + it.group + '</td>'
        html+='<td class="col-md-2">' + it.name + '</td>'
        html+='<td class="col-md-2">' + it.version + '</td>'
        html+='<td class="col-md-2">' + it.downloaded + '</td>'
        html+='<td class="col-md-2">' + it.deployed + '</td>'
        html+='<td class="col-md-2">' + it.status + '</td>'
        html+='</tr>'
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
                    jsonForReporting = json
                }
            }
        }
        stage('Deploy Spring component') {
            when { expression {!json.delivery.deployed } } //  && env.BRANCH_NAME.startsWith('release')
            steps {
                script {
                    for (String item : jsonForReporting.delivery.spring) {
                        try {
                            println("Download of " + item.group + ":" + item.name + ":" + item.version)
                            try {
                                sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=" + item.group + ":" + item.name + ":" + item.version + ":war -DoutputDirectory=."

                                item.downloaded = true
                            }catch(e) {
                                item.downloaded = false
                                item.deployed = false
                                throw new Exception("Can't find the artefact " + item.group + ":" + item.name + ":" + item.version)
                            }

                            if (!params['Dry run ?']) {
                                println("Deployment of " + item.group + ":" + item.name + ":" + item.version)
                                try {
                                    sh "mvn tomcat7:deploy-only -Dpath=/" + item.name + " -DwarFile=" + item.name + "-" + item.version + ".war"
                                    item.deployed = true
                                }catch(e) {
                                    item.deployed = false
                                    throw new Exception("Can't deployed the artefact " + item.group + ":" + item.name + ":" + item.version)
                                }
                            } else {
                                item.deployed = false
                            }

                            item.status = 'OK'
                        }catch(e){
                            item.status = 'IN ERROR'
                        }
                    }
                }
            }
        }
        stage('Deploy GCM APP') {
            when { expression {!json.delivery.deployed } } //  && env.BRANCH_NAME.startsWith('release')
            steps {
                script {
                    for (String item : jsonForReporting.delivery.adf_app) {
                        try {
                            println("Download of " + item.group + ":" + item.name + ":" + item.version)
                            try {
                                sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=" + item.group + ":" + item.name + ":" + item.version + ":ear -DoutputDirectory=."
                                sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=" + item.group + ":" + item.name + ":" + item.version + ":jar:cfgplan -DoutputDirectory=."

                                item.downloaded = true
                            }catch(e) {
                                item.downloaded = false
                                item.deployed = false
                                throw new Exception("Can't find the artefact " + item.group + ":" + item.name + ":" + item.version)
                            }


                                item.deployed = false


                            item.status = 'OK'
                        }catch(e){
                            item.status = 'IN ERROR'
                        }
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
                    /*
                    sh "rm -rf delivery.json"

                    json.delivery.deployed = true
                    writeJSON json: json, file: 'delivery.json', pretty: 2

                    sh "git add delivery.json"
                    sh 'git commit -m "locking of this version"'
                    sh "git push --set-upstream origin ${env.BRANCH_NAME}"

                     */
                }
            }
        }
        always {
            script {
                buildHTMLReport(jsonForReporting)
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
