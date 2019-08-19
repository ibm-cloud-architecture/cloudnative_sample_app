def cloud = env.CLOUD ?: "openshift"
def servicePort = env.SERVICE_PORT ?: "8080"
def imageName = env.IMAGE_NAME ?: "greeting"
def podLabel = "sample"
podTemplate(
    label: podLabel,
    cloud: cloud,
    envVars: [
        envVar(key: 'SERVICE_PORT', value: servicePort),
        envVar(key: 'IMAGE_NAME', value: imageName),
        envVar(key: 'BUILD_NUMBER', value: "${env.BUILD_NUMBER}")
    ],
    containers: [
        containerTemplate(
            name: 'maven',
            image: 'maven:3-alpine',
            ttyEnabled: true,
            command: '/bin/bash',
            workingDir: '/home/jenkins',
            envVars: [
                envVar(key: 'HOME', value: '/home/jenkins')
            ]
        ),
        containerTemplate(
            name: 'ibmcloud',
            image: 'docker.io/garagecatalyst/ibmcloud-dev:1.0.7',
            ttyEnabled: true,
            command: '/bin/bash',
            workingDir: '/home/jenkins',
            envVars: [
                envVar(key: 'HOME', value: '/home/devops')
            ]
        )
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

        container(name: 'ibmcloud', shell: '/bin/bash') {
            stage('Build and Push Image') {
                withCredentials(
                 [string(credentialsId: 'registry_url', variable: 'REGISTRY_URL'),
                  string(credentialsId: 'registry_namespace', variable: 'REGISTRY_NAMESPACE'),
                  string(credentialsId: 'ibm_cloud_region', variable: 'REGION'),
                  string(credentialsId: 'ibm_cloud_api_key', variable: 'APIKEY')]) {
                sh '''#!/bin/bash
                    set -x

                    ibmcloud login -r ${REGION} --apikey ${APIKEY}

                    ibmcloud cr login

                    echo "Checking registry namespace: ${REGISTRY_NAMESPACE}"
                    NS=$( ibmcloud cr namespaces | grep ${REGISTRY_NAMESPACE} ||: )
                    if [[ -z "${NS}" ]]; then
                        echo -e "Registry namespace ${REGISTRY_NAMESPACE} not found, creating it."
                        ibmcloud cr namespace-add ${REGISTRY_NAMESPACE}
                    else
                        echo -e "Registry namespace ${REGISTRY_NAMESPACE} found."
                    fi

                    echo -e "Existing images in registry"
                    ibmcloud cr images --restrict "${REGISTRY_NAMESPACE}/${IMAGE_NAME}"


                    echo -e "=========================================================================================="
                    echo -e "BUILDING CONTAINER IMAGE: ${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}:${BUILD_NUMBER}"
                    set -x
                    ibmcloud cr build -f Dockerfile.multistage -t ${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}:${BUILD_NUMBER} .

                    echo -e "Available images in registry"
                    ibmcloud cr images --restrict ${REGISTRY_NAMESPACE}/${IMAGE_NAME}

                '''
                }
            }
            stage('Push to Deploy repo') {
                sh "mkdir -p deploy"

                dir ('deploy') {
                  git url: "https://github.com/ibm-cloud-architecture/cloudnative_sample_app_deploy.git",
                      branch: "master",
                      credentialsId: "github-credentials-id"

                  sh "find ."

                  withCredentials(
                   [string(credentialsId: 'git-account', variable: 'GIT_USER_ACCOUNT'),
                    string(credentialsId: 'github-token', variable: 'GITHUB_API_TOKEN')]) {

                  sh """
                     git config user.email "jenkins@jenkins.com"
                     git config user.name "jenkins"
                     cd chart/cloudnativesampleapp
                     sed -i.bak '/^image/,/^service/ s/\\(\\s*tag\\s*:\\s*\\).*/\\ \\ tag: '${BUILD_NUMBER}'/g' values.yaml
                     rm values.yaml.bak
                     git add . *.yaml
                     git commit -m "Jenkins commit: ${BUILD_NUMBER}"
                     git remote rm origin
                     git remote add origin https://${GIT_USER_ACCOUNT}:${GITHUB_API_TOKEN}@github.com/ibm-cloud-architecture/cloudnative_sample_app_deploy.git > /dev/null 2>&1
                     git push origin master
                """
                }
              }

            }

        }

    }
}
