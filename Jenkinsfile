pipeline {
    agent any
    environment {
        SERVICE_PORT = 8080
        IMAGE_NAME = "greeting"
    }
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'maven:3-alpine'
                    args '-v /root/.m2:/root/.m2'
                }
            }
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            agent {
                docker {
                    image 'maven:3-alpine'
                    args '-v /root/.m2:/root/.m2'
                }
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
                docker {
                    image 'maven:3-alpine'
                    args '-v /root/.m2:/root/.m2'
                }
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
        stage('Docker - Build Image') {
            steps{
                sh """
                    IMAGE=${env.IMAGE_NAME}:${env.BUILD_NUMBER}
                    docker build -f Dockerfile.multistage -t \${IMAGE} .
                """
            }
        }
    }
}
