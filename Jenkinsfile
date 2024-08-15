pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sessioncookieapp:latest'
        CONTAINER_NAME = 'tomcat_sessioncookieapp'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://your-repo-url.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE)
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // 기존 컨테이너가 있으면 종료 및 삭제
                    sh """
                    if [ \$(docker ps -aq -f name=\${CONTAINER_NAME}) ]; then
                        docker stop \${CONTAINER_NAME}
                        docker rm \${CONTAINER_NAME}
                    fi
                    """
                    // 새로운 컨테이너 실행
                    docker.image(DOCKER_IMAGE).run('-d -p 8080:8080 --name \${CONTAINER_NAME}')
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up Docker containers...'
            sh 'docker system prune -f'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed. Check the logs for details.'
        }
    }
}
