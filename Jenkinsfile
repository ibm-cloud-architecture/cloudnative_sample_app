def buildLabel = "agent.${env.JOB_NAME}.${env.BUILD_NUMBER}".replace('-', '_').replace('/', '_')
podTemplate(
   label: buildLabel,
   containers: [
      containerTemplate(
         name: 'maven',
         image: 'maven:3-alpine',
         ttyEnabled: true,
         command: '/bin/bash',
         workingDir: '/home/jenkins',
         envVars: [
            envVar(key: 'DOCKER_CONFIG', value: '/home/jenkins/.docker/'),
         ],
      ),
   ],
   serviceAccount: 'jenkins'
) {
    node(buildLabel) {
        container(name: 'maven', shell: '/bin/bash') {
            checkout scm
            stage('Setup') {
                sh '''#!/bin/bash
                    set -x
                    mvn -v
                '''
            }
            stage('Build') {
                sh '''#!/bin/bash
                    set -x
                    mvn -B -DskipTests clean package
                '''
            }
            stage('Test') {
                steps {
                    sh 'mvn test'
                }
                post {
                    always {
                        junit 'target/surefire-reports/*.xml'
                    }
                }
            }
        }
    }
}
