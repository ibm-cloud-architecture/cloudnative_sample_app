def cloud = env.CLOUD ?: "openshift"
def podLabel = "sample"
podTemplate(
    label: podLabel,
    cloud: cloud
) {
    node(podLabel) {
        stage('Run shell') {
            sh 'echo hello world'
        }
    }
}
