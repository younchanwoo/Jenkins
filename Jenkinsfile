pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sessioncookieapp:latest'
        CONTAINER_NAME = 'tomcat_sessioncookieapp'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/younchanwoo/Jenkins.git'
            }
        }

        stage('Build Podman Image') {
            steps {
                script {
                    // 이 단계에서 Dockerfile을 사용하여 이미지를 빌드합니다.
                    sh 'podman build --no-cache -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // 기존 컨테이너가 있으면 종료 및 삭제
                    sh """
                    if [ \$(podman ps -aq -f name=\${CONTAINER_NAME}) ]; then
                        podman stop \${CONTAINER_NAME}
                        podman rm \${CONTAINER_NAME}
                    fi
                    """
                    // 새로운 컨테이너 실행
                    sh 'podman run -d -p 8080:8080 --name ${CONTAINER_NAME} ${DOCKER_IMAGE}'
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Podman containers...'
            sh 'podman system prune -f'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed. Check the logs for details.'
        }
    }
}
