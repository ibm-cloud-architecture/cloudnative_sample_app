pipeline {

    agent {
      label "maven"
    }

    stages {

        agent {
          label "maven"
        }

        stage('Maven build') {
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
          post {
            always {
                junit 'target/surefire-reports/*.xml'
            }
          }

        }

        // Docker test
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
