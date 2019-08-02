def CONTAINER_NAME="cloudnativesampleapp"

node {

    stage('Initialize'){
        def dockerHome = tool 'myDocker'
        def mavenHome  = tool 'myMaven'
        env.PATH = "${dockerHome}/bin:${mavenHome}/bin:${env.PATH}"
    }

    stage('Checkout') {
        checkout scm
    }

    stage('Build'){
        sh 'mvn -B -DskipTests clean package'
    }

    stage('Test'){
        sh 'mvn test'
    }

    stage("Image Prune"){
        imagePrune(CONTAINER_NAME)
    }

}

def imagePrune(containerName){
    try {
        sh "docker image prune -f"
        sh "docker stop $containerName"
    } catch(error){}
}
