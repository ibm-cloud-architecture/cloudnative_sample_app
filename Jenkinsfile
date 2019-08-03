def cloud = "openshift"
podTemplate(
    cloud: cloud
) {
    node(POD_LABEL) {
        stage('Run shell') {
            sh 'echo hello world'
        }
    }
}
