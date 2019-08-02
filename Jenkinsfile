pipeline {
    agent any

    stages {
        stage('Build') {
            agent {
              label "maven"
            }
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            agent {
              label "maven"
            }
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Deliver') {
            agent {
              label "maven"
            }
            steps {
                sh """
                    #!/bin/bash
                    java -jar ./target/cloudnativesampleapp-1.0-SNAPSHOT.jar &
                    PID=`echo \$!`
                    # Wait for the app to start
                    sleep 20
                    sh scripts/health_check.sh
                    sh scripts/api_tests.sh 127.0.0.1 ${env.SERVICE_PORT}
                    # Kill process
                    kill \${PID}
                """
            }
        }
    }
}
