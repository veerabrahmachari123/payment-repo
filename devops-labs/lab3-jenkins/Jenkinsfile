pipeline {
    agent any

    environment {
        IMAGE = "mycompany/payment"
        TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Build') {
            steps {
                sh '''
                    docker build -t $IMAGE:$TAG .
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    docker run $IMAGE:$TAG pytest
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker stop payment || true
                    docker rm payment || true

                    docker run -d \
                      --name payment \
                      -p 8080:8080 \
                      $IMAGE:latest
                '''
            }
        }
    }
}
