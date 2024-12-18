pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building application...'
                sh '''
                npm install
                tar -czf app.tar.gz *
                '''
            }
        }

        stage('Build Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                oc new-build --binary --name=openshift-test-app -n test-app || true
                oc start-build openshift-test-app --from-dir=. -n test-app --follow
                '''
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh '''
                oc new-app openshift-test-app -n test-app || oc rollout latest dc/openshift-test-app -n test-app
                oc expose svc/openshift-test-app -n test-app || true
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
