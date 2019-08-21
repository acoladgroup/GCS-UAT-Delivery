def json
def htmlContent = '<html><head><link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous"><script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script></head><body>'

pipeline {
    agent  { node { label 'alt' } }
    parameters {
        booleanParam(name: "Dry run ?", description: 'Be carefull, you will deploy this version on UAT environment', defaultValue: true)
    }
    environment {
        JAVA_HOME = "/usr/lib/jvm/java-8-oracle"
    }
    stages {
        stage('Init') {
            steps {
                script {
                    echo "Deployment of the release from ${env.BRANCH_NAME}"
                    htmlContent += "<h1>Deployment of the version ${env.BRANCH_NAME}</h1>"
                    htmlContent += "<p>Dry run : ${params['Dry run ?']}</p>"

                    if (params['Dry run ?']) {
                        htmlContent += "<p><b>No composite will be deployed in this mode</b></p>" 
                    }
                }
            }
        }
        stage('Read delivery file') {
            steps {
                script {
                    json = readJSON file: 'delivery.json'

                    if (json.delivery.deployed) {
                        htmlContent += '<p><b>This version is already deployed. Nothing will be deployed again<b></p>'
                    }
                }
            }
        }
        stage('Deploy Spring component') {
            when { expression {!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') } }
            steps {
                script {
                    htmlContent += "<h2>Deployment of Spring element(s)</h2><ul>"

                    for (String item : json.delivery.spring) {
                        println("Download of ${item.groupId}:${item.artefactId}:${item.version}")
                        sh "mvn org.apache.maven.plugins:maven-dependency-plugin:3.1.1:copy -Dartifact=${item.groupId}:${item.artefactId}:${item.version}:war -DoutputDirectory=."

                        if (!params['Dry run ?']) {
                            println("Deploy of ${item.groupId}:${item.artefactId}:${item.version}")
                            sh "mvn tomcat7:deploy-only -Dpath=/${item.artefactId} -DwarFile=${item.artefactId}-${item.version}.war"
                        }

                        htmlContent += "<li>${item.artefactId} in version ${item.version}</li>"
                    }

                    htmlContent += "</ul>"
                }
            }
        }
    }
    post {
        success {
            script {
                // Lock the delivery file to avoid a second execution
                if (!json.delivery.deployed && env.BRANCH_NAME.startsWith('release') && !params['Dry run ?']) {
                    sh "del -f delivery.json"

                    json.delivery.deployed = true
                    writeJSON json: json, file: 'delivery.json', pretty: 2

                    sh "git add delivery.json"
                    sh 'git commit -m "locking of this version"'
                    sh "git push --set-upstream origin ${env.BRANCH_NAME}"
                }
            }
        }
        failure {
            mail to: 'DL_INT_IT-MiddlewareOperations@amplexor.com',
                    subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                    body: "Something is wrong with ${env.BUILD_URL}"
        }
        always {
            script {
                htmlContent += "<h3>End of deployment</h3></body></html>"

                mail mimeType: 'text/html',
                        to: 'DL_INT_IT-MiddlewareOperations@amplexor.com',
                        subject: "Report for the deployment of version ${env.BRANCH_NAME}",
                        body: htmlContent
            }
        }
    }
}
