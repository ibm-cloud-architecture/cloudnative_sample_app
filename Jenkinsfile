pipeline {
    agent any
    environment {
        SERVICE_PORT = 8080
        IMAGE_NAME = "greeting"
        RELEASE_NAME= "cloudnativesampleapp"
        EXPOSE_PORT = 8081
        DOCKERHUB_CREDS = credentials('registry-credentials-id')
        DOCKER_REPO= "ibmcase"
    }
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'maven:3-alpine'
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
        stage('Docker - Run and Test') {
            steps{
                sh """
                    #!/bin/bash
                    # Get image
                    IMAGE=${env.IMAGE_NAME}:${env.BUILD_NUMBER}
                    # Kill Container if it already exists
                    docker kill ${env.RELEASE_NAME} || true
                    docker rm ${env.RELEASE_NAME} || true
                    # Start Container
                    echo "Starting ${env.RELEASE_NAME} container"
                    set +x
                    docker run --name ${env.RELEASE_NAME} -d \
                        -p ${env.EXPOSE_PORT}:${env.SERVICE_PORT} \
                        \${IMAGE}
                    set -x
                    # Check that application started successfully
                    docker ps
                    # Check the logs
                    docker logs -f ${env.RELEASE_NAME} &
                    PID=`echo \$!`
                    # Get the container IP Address
                    # CONTAINER_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${env.RELEASE_NAME}`
                    # Wait for the app to start
                    sleep 20
                    # Test the health
                    # sh scripts/health_check.sh "http://localhost:${env.EXPOSE_PORT}"
                    # Run tests
                    # sh scripts/api_tests.sh 127.0.0.1 ${env.EXPOSE_PORT}
                    # Kill process
                    kill \${PID}
                    # Kill Container
                    docker kill ${env.RELEASE_NAME} || true
                    docker rm ${env.RELEASE_NAME} || true
                """
            }
        }
        stage('Docker - Push Image to Registry') {
            agent any
            steps{
                sh """
                    #!/bin/bash
                    # Get image
                    IMAGE=${env.IMAGE_NAME}:${env.BUILD_NUMBER}
                    # Tag the image
                    docker tag \${IMAGE} ${env.DOCKER_REPO}/\${IMAGE}
                    # Login to dockerhub
                    docker login -u ${DOCKERHUB_CREDS_USR} -p ${DOCKERHUB_CREDS_PSW}
                    # Push the image
                    docker push ${env.DOCKER_REPO}/\${IMAGE}
                """
            }
        }
    }
}
