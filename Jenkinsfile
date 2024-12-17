pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building application...'
                sh '''
                # 安裝依賴並打包應用程式
                npm install
                tar -czf app.tar.gz *
                '''
            }
        }

        stage('Build Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                docker build -t image-registry.openshift-image-registry.svc:5000/test-app/openshift-test-app:latest .
                '''
            }
        }

        stage('Push Image') {
            steps {
                echo 'Pushing Docker image to OpenShift registry...'
                sh '''
                docker login -u $(oc whoami) -p $(oc whoami -t) image-registry.openshift-image-registry.svc:5000
                docker push image-registry.openshift-image-registry.svc:5000/test-app/openshift-test-app:latest
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application to OpenShift...'
                sh '''
                oc new-app image-registry.openshift-image-registry.svc:5000/test-app/openshift-test-app:latest --name=openshift-test-app -n test-app || oc rollout latest dc/openshift-test-app -n test-app
                oc expose svc/openshift-test-app -n test-app || true
                '''
            }
        }
    }
    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}
