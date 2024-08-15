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
                    sh 'podman build --no-cache -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    sh """
                    if [ \$(podman ps -aq -f name=\${CONTAINER_NAME}) ]; then
                        podman stop \${CONTAINER_NAME}
                        podman rm \${CONTAINER_NAME}
                    fi
                    """
                    sh 'podman run -d -p 8080:8080 --name ${CONTAINER_NAME} ${DOCKER_IMAGE}'
                    
                    // 컨테이너가 정상적으로 실행되고 있는지 확인
                    sh 'podman ps'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
            // 컨테이너 로그 출력
            sh 'podman logs ${CONTAINER_NAME} || echo "No logs available"'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed. Check the logs for details.'
        }
    }
}
