pipeline {

    agent {
      label "maven"
    }

    stages {

        stage('Maven build') {
          steps {
            sh 'mvn -B -DskipTests clean package'
          }
        }

        // Run Maven unit tests
        stage('Unit Test'){
          steps {
            sh 'mvn test'
          }
        }
    }
}
