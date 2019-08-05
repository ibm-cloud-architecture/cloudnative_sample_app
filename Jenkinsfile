def cloud = env.CLOUD ?: "openshift"
def servicePort = env.SERVICE_PORT ?: "8080"
def imageName = env.IMAGE_NAME ?: "greeting"
def namespace = env.NAMESPACE ?: "default"
def podLabel = "sample"
podTemplate(
    label: podLabel,
    cloud: cloud,
    envVars: [
        envVar(key: 'SERVICE_PORT', value: servicePort),
        envVar(key: 'IMAGE_NAME', value: imageName),
        envVar(key: 'NAMESPACE', value: namespace),
        envVar(key: 'BUILD_NUMBER', value: "${env.BUILD_NUMBER}")
    ],
    containers: [
        containerTemplate(
            name: 'maven',
            image: 'maven:3-alpine',
            ttyEnabled: true,
            command: '/bin/bash',
            workingDir: '/home/jenkins'
        ),
        containerTemplate(
            name: 'ibmcloud',
            image: 'docker.io/garagecatalyst/ibmcloud-dev:1.0.5',
            ttyEnabled: true,
            command: '/bin/bash',
            workingDir: '/home/jenkins',
            envVars: [
                envVar(key: 'DOCKER_CONFIG', value: '/home/jenkins/.docker/'),
                envVar(key: 'APIURL', value: 'https://cloud.ibm.com'),
                secretEnvVar(key: 'REGISTRY_URL', secretName: 'ibmcloud-apikey', secretKey: 'registry_url'),
                secretEnvVar(key: 'REGISTRY_NAMESPACE', secretName: 'ibmcloud-apikey', secretKey: 'registry_namespace'),
                secretEnvVar(key: 'REGION', secretName: 'ibmcloud-apikey', secretKey: 'region'),
                secretEnvVar(key: 'APIKEY', secretName: 'ibmcloud-apikey', secretKey: 'password'),
                secretEnvVar(key: 'RESOURCE_GROUP', secretName: 'ibmcloud-apikey', secretKey: 'resource_group'),
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
            stage('Verify environment') {
                sh '''#!/bin/bash
                    set -x

                    whoami

                    if [[ -z "${APIKEY}" ]]; then
                      echo "APIKEY is required"
                      exit 1
                    fi

                    if [[ -z "${RESOURCE_GROUP}" ]]; then
                      echo "RESOURCE_GROUP is required"
                      exit 1
                    fi

                    if [[ -z "${REGION}" ]]; then
                      echo "REGION is required"
                      exit 1
                    fi

                    if [[ -z "${REGISTRY_NAMESPACE}" ]]; then
                      echo "REGISTRY_NAMESPACE is required"
                      exit 1
                    fi

                    if [[ -z "${REGISTRY_URL}" ]]; then
                      echo "REGISTRY_URL is required"
                      exit 1
                    fi
                '''
            }
            stage('Build and Push Image') {
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
            stage('Push to Deploy repo') {
                sh "mkdir -p deploy"

                dir ('deploy') {
                  git url: "https://github.com/Hemankita/cloudnative_sample_app_deploy.git",
                      branch: "master",
                      credentialsId: "github-credentials-id"

                  sh "find ."

                  withCredentials([usernamePassword(credentialsId: 'github-credentials-id',
                                                    usernameVariable: 'USERNAME',
                                                    passwordVariable: 'PASSWORD')]) {

                  println(env.USERNAME)
                  println(env.PASSWORDcd)
                  sh """
                     git config user.email "jenkins@jenkins.com"
                     git config user.name "jenkins"
                     cd chart/cloudnativesampleapp
                     sed -i.bak '/^image/,/^service/ s/\\(\\s*tag\\s*:\\s*\\).*/\\ \\ tag: '${BUILD_NUMBER}'/g' values.yaml
                     rm values.yaml.bak
                     git add . *.yaml
                     git commit -m "Jenkins commit: ${BUILD_NUMBER}"
                     git config --global credential.username {USERNAME}
                     git config --global credential.helper "!echo password={PASSWORD}; echo"
                     git push origin master
                """
                }
              }

            }

        }

    }
}
