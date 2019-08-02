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
