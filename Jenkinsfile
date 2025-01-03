pipeline {
    agent any
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
                container('nodejs') {
                    echo '開始構建應用程式...'
                    sh '''
                    npm install
                    tar -czf app.tar.gz *
                    '''
                }
            }
        }

        stage('Build Image') {
            agent any
            steps {
                script{
                    echo '構建 Docker 映像...'
                    sh '''
                    oc new-build --binary --name=openshift-test-app || true
                    oc start-build openshift-test-app --from-dir=. --follow
                    ''' 
                }                
            }
        }

        stage('Deploy') {
            agent any
            steps {
                script {
                    echo '部署應用程式...'
                    sh '''
                    oc new-app openshift-test-app || oc rollout restart deploy openshift-test-app
                    #oc expose svc/openshift-test-app
                    oc set resources deployment openshift-test-app --limits=cpu=500m,memory=256Mi --requests=cpu=250m,memory=128Mi
                    oc apply -f hpa.yaml
                    oc apply -f route.yaml
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
