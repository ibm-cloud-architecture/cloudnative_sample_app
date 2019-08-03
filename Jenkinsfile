def cloud = "openshift"
def podLabel = "sample"
podTemplate(
    label: podLabel,
    cloud: "openshift"
) {
    node(podLabel) {
        stage('Run shell') {
            sh 'echo hello world'
        }
    }
}
