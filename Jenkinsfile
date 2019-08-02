// Pod Template
def podLabel = "sampleapp"
def cloud = env.CLOUD ?: "kubernetes"
def registryCredsID = env.REGISTRY_CREDENTIALS ?: "registry-credentials-id"
def serviceAccount = env.SERVICE_ACCOUNT ?: "jenkins"

podTemplate(label: podLabel, cloud: cloud, serviceAccount: serviceAccount,
    volumes: [
        emptyDirVolume(mountPath: '/var/lib/docker', memory: false)
    ],
    containers: [
        containerTemplate(name: 'maven', image: 'maven:3-alpine', ttyEnabled: true, command: 'cat')
  ])
  {
      node {

          stage('Checkout') {
              checkout scm
          }

          // Local
          container(name:'maven', shell:'/bin/bash') {
              stage('Local - Build') {
                  sh 'mvn -B -DskipTests clean package'
              }
          }

      }
    }
