pipeline {
    agent none  // 預設無 agent，每個 stage 自行指定
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
                container('nodejs') { // 指定在 nodejs 容器中執行
                    echo 'Building application...'
                    sh '''
                    npm install
                    tar -czf app.tar.gz *
                    '''
                }
            }
        }

        stage('Build Image') {
            agent { label 'jenkins-node' } // 指定在 Jenkins 節點上執行
            steps {
                echo 'Building Docker image...'
                sh '''
                oc new-build --binary --name=openshift-test-app || true
                oc start-build openshift-test-app --from-dir=. --follow
                '''
            }
        }

        stage('Deploy') {
            agent { label 'jenkins-node' } // 指定在 Jenkins 節點上執行
            steps {
                echo 'Deploying application...'
                sh '''
                oc new-app openshift-test-app || oc rollout latest dc/openshift-test-app -n test-app
                oc expose svc/openshift-test-app  || true
                '''
            }
        }
    }
    post {
        success {
            echo 'Application deployed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
