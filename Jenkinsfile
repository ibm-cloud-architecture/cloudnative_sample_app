def cloud = env.CLOUD_NAME == "openshift" ? "openshift" : "kubernetes"
podTemplate(
    cloud: cloud
) {
    node(POD_LABEL) {
        stage('Run shell') {
            sh 'echo hello world'
        }
    }
}
