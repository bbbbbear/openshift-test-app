pipeline {
    agent any

    environment {
        APP_NAME = "openshift-test-app"              // 應用程式名稱
        NAMESPACE = "test-app"                       // OpenShift 專案名稱
        IMAGE_REGISTRY = "image-registry.openshift-image-registry.svc:5000/${NAMESPACE}/${APP_NAME}"
    }

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
                sh """
                docker build -t ${IMAGE_REGISTRY}:latest .
                """
            }
        }

        stage('Push Image') {
            steps {
                echo 'Pushing Docker image to OpenShift registry...'
                sh """
                docker login -u $(oc whoami) -p $(oc whoami -t) image-registry.openshift-image-registry.svc:5000
                docker push ${IMAGE_REGISTRY}:latest
                """
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application to OpenShift...'
                sh """
                oc new-app ${IMAGE_REGISTRY}:latest --name=${APP_NAME} -n ${NAMESPACE} || oc rollout latest dc/${APP_NAME} -n ${NAMESPACE}
                oc expose svc/${APP_NAME} -n ${NAMESPACE} || true
                """
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
