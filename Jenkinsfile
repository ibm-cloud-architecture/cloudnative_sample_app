def cloud = "openshift"
podTemplate(
    cloud: "openshift"
) {
    node(POD_LABEL) {
        stage('Run shell') {
            sh 'echo hello world'
        }
    }
}
