def cloud = env.CLOUD ?: "openshift"
def podLabel = "sample"
podTemplate(
    label: podLabel,
    cloud: cloud,
    volumes: [
        emptyDirVolume(mountPath: '/var/lib/docker', memory: false)
    ],
    containers: [
        containerTemplate(name: 'maven', image: 'maven:3-alpine', ttyEnabled: true, command: '/bin/bash')
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
        }
    }
}
