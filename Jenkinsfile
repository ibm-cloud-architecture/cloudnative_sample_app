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
    }
}
