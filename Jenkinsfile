pipeline {
    agent none  // 不使用全局的 Agent
    stages {
        stage('Build') {
            agent {
                kubernetes {
                    yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: nodejs
    image: node:18
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
  volumes:
  - emptyDir: {}
    name: "workspace-volume"
"""
                }
            }
            steps {
                container('nodejs') { // 在 nodejs 容器中執行
                    echo '開始構建應用程式...'
                    sh '''
                    npm install
                    tar -czf app.tar.gz *
                    '''
                }
            }
        }

        stage('Build Image') {
            agent {
                kubernetes {
                    yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: oc-cli
    image: quay.io/openshift/origin-cli:4.10
    command:
    - cat
    tty: true
"""
                }
            }
            steps {
                container('oc-cli') { // 使用包含 oc 的 OpenShift CLI 容器
                    echo '構建 Docker 映像...'
                    sh '''
                    oc new-build --binary --name=openshift-test-app || true
                    oc start-build openshift-test-app --from-dir=. --follow
                    '''
                }
            }
        }

        stage('Deploy') {
            agent {
                kubernetes {
                    yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: oc-cli
    image: quay.io/openshift/origin-cli:4.10
    command:
    - cat
    tty: true
"""
                }
            }
            steps {
                container('oc-cli') { // 使用 OpenShift CLI 容器
                    echo '部署應用程式...'
                    sh '''
                    oc new-app openshift-test-app -n test-app || oc rollout latest dc/openshift-test-app -n test-app
                    oc expose svc/openshift-test-app -n test-app || true
                    '''
                }
            }
        }
    }
    post {
        success {
            echo '應用程式已成功部署！'
        }
        failure {
            echo 'Pipeline 執行失敗！'
        }
    }
}
