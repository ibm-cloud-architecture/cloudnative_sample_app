def cloud = env.CLOUD ?: "openshift"
def servicePort = env.SERVICE_PORT ?: "8080"
def registry = env.REGISTRY ?: "docker.io"
def imageName = env.IMAGE_NAME ?: "ibmcase/greeting"
def namespace = env.NAMESPACE ?: "default"
def podLabel = "sample"
podTemplate(
    label: podLabel,
    cloud: cloud,
    envVars: [
        envVar(key: 'SERVICE_PORT', value: servicePort),
        envVar(key: 'REGISTRY', value: registry),
        envVar(key: 'IMAGE_NAME', value: imageName),
        envVar(key: 'NAMESPACE', value: namespace),
    ],
    containers: [
        containerTemplate(name: 'maven', image: 'maven:3-alpine', ttyEnabled: true, command: '/bin/bash'),
        containerTemplate(name: 'ibmcloud', image: 'docker.io/garagecatalyst/ibmcloud-dev:1.0.5', ttyEnabled: true, command: '/bin/bash', workingDir: '/home/jenkins', envVars: [envVar(key: 'DOCKER_CONFIG', value: '/home/jenkins/.docker/')])
    ]
) {
    node(podLabel) {
        checkout scm

        container(name:'maven', shell:'/bin/bash') {
            stage('Local - Build') {
                sh 'mvn -B -DskipTests clean package'
            }
            stage('Local - Test') {
                sh 'mvn test'
            }
            stage('Local - Run') {
                sh """
                    #!/bin/bash
                    java -jar ./target/cloudnativesampleapp-1.0-SNAPSHOT.jar &
                    PID=`echo \$!`
                    # Wait for the app to start
                    sleep 20
                    sh scripts/health_check.sh
                    sh scripts/api_tests.sh 127.0.0.1 ${SERVICE_PORT}
                    # Kill process
                    kill \${PID}
                """
            }
        }

    }
}
