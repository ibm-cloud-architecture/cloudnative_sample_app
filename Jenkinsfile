def podLabel = "sample_app"
node(podLabel) {

    checkout scm

    // Local
    container(name:'maven:3-alpine', shell:'/bin/bash') {
        stage('Local - Build and Unit Test') {
            sh 'mvn -B -DskipTests clean package'
        }
    }
}
