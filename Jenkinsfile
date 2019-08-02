def CONTAINER_NAME="cloudnativesampleapp"
def IMAGE_NAME="greeting"

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

    stage('Image Build'){
        imageBuild(IMAGE_NAME, ${env.BUILD_NUMBER})
    }

}

def imagePrune(containerName){
    try {
        sh "docker image prune -f"
        sh "docker stop $containerName"
    } catch(error){}
}

def imageBuild(containerName, tag){
    sh "docker build -f Dockerfile.multistage -t $containerName:$tag  -t $containerName --pull --no-cache ."
    echo "Image build complete"
}
