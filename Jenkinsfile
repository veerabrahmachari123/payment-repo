pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        REGISTRY = 'localhost:5000'
        IMAGE    = 'mycompany/payment'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    env.GIT_FULL  = sh(script: 'git rev-parse HEAD',
                                       returnStdout: true).trim()
                    env.GIT_SHORT = sh(script: 'git rev-parse --short=7 HEAD',
                                       returnStdout: true).trim()
                    env.BRANCH    = env.BRANCH_NAME ?: 'main'
                    env.TAG       = "${env.BUILD_NUMBER}-${env.GIT_SHORT}"
                }
                sh '''
                    docker build \
                      --build-arg APP_VERSION=$TAG \
                      --build-arg GIT_COMMIT=$GIT_FULL \
                      --build-arg BRANCH_NAME=$BRANCH \
                      --build-arg BUILD_NUMBER=$BUILD_NUMBER \
                      -t $IMAGE:$TAG .
                '''
            }
        }

        stage('Test') {
            steps {
                sh 'docker run --rm $IMAGE:$TAG pytest -q -p no:cacheprovider'
            }
        }

        stage('Tag') {
            steps {
                sh '''
                    docker tag $IMAGE:$TAG $REGISTRY/$IMAGE:$TAG
                    docker tag $IMAGE:$TAG $REGISTRY/$IMAGE:latest
                '''
            }
        }

        stage('Push') {
            steps {
                sh '''
                    docker push $REGISTRY/$IMAGE:$TAG
                    docker push $REGISTRY/$IMAGE:latest
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker pull $REGISTRY/$IMAGE:$TAG
                    docker stop payment || true
                    docker rm payment || true

                    docker run -d \
                      --name payment \
                      -p 8090:8080 \
                      $REGISTRY/$IMAGE:$TAG

                    echo "=============== DEPLOYED ==============="
                    echo "App version   : $(docker exec payment printenv APP_VERSION)"
                    echo "Git commit    : $(docker exec payment printenv GIT_COMMIT)"
                    echo "Docker image  : $REGISTRY/$IMAGE:$TAG"
                    echo "Jenkins build : #$BUILD_NUMBER"
                '''
            }
        }
    }
}