pipeline {

    agent any

    stages {

        stage('Maven build') {
          agent {
            label "maven"
          }
          steps {
            sh 'mvn -B -DskipTests clean package'
          }
        }

        // Run Maven unit tests
        stage('Unit Test'){
          agent {
            label "maven"
          }
          steps {
            sh 'mvn test'
          }
        }

        // Run Maven unit tests
        stage('Unit Test'){
          agent {
            label "maven"
          }
          steps {
            sh 'mvn test'
          }
        }

        // Docker tests
        stage('Docker Test'){
          agent {
            label "docker"
          }
          steps {
            sh 'docker -v'
          }
        }

    }
}
