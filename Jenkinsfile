pipeline {

    options {
        // Build auto timeout
        timeout(time: 60, unit: 'MINUTES')
    }

    // Some global default variables
    environment {
        IMAGE_NAME = 'greeting'
        TEST_LOCAL_PORT = 8080
    }

    parameters {
        string (name: 'GIT_BRANCH',           defaultValue: 'master',  description: 'Git branch to build')
    }

    // In this example, all is built and run from the master
    agent { node { label 'master' } }

    // Pipeline stages
    stages {

        ////////// Step 1 //////////
        stage('Git clone and setup') {
            steps {
                echo "Check out acme code"
                git branch: "master",
                        credentialsId: 'github-credentials',
                        url: 'https://github.com/Hemankita/cloudnative_sample_app.git'

                // Validate kubectl
                sh "kubectl cluster-info"

                // Init helm client
                sh "helm init"

            }
        }
    }
}
