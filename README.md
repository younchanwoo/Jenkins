# Jenkins 설치 가이드 for Fedora 39 with Java 17

이 문서는 Fedora 39에서 Java 17을 사용하여 Jenkins를 설치하는 간단한 가이드입니다.

# 사전 요구 사항
* Jenkins 설치 및 실행
* Docker & podman 설치
* Git 저장소 접근 권한

# 1. Jenkins 설치
## 1.1. 스크립트 준비
아래 스크립트는 Jenkins를 설치하고 기본 설정을 완료하는 데 사용됩니다. 스크립트를 install.sh 파일로 저장하고 실행합니다.
```
#!/bin/bash

# 스크립트를 루트 권한으로 실행하는지 확인합니다.
if [ "$EUID" -ne 0 ]; then
  echo "이 스크립트를 루트 권한으로 실행해야 합니다."
  exit
fi

# 시스템 업데이트
dnf -y update

# Java 17 설치
dnf install -y java-17-openjdk

# Jenkins 저장소 추가 및 GPG 키 가져오기
dnf config-manager --add-repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key

# Jenkins 패키지 설치 (GPG 체크 활성화)
dnf install -y jenkins

# Jenkins 서비스가 제대로 설치되었는지 확인
if ! systemctl list-unit-files | grep -q jenkins.service; then
    echo "Jenkins 서비스 파일이 설치되지 않았습니다. 설치를 다시 시도하세요."
    exit 1
fi

# Jenkins 서비스를 시작하고 부팅 시 자동 시작 설정
systemctl enable --now jenkins

# Jenkins 초기화가 완료될 때까지 대기 (약 30초, 상황에 따라 조정 가능)
sleep 30

# 방화벽에서 Jenkins 포트(8080) 열기
firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --reload

# 설치 및 서비스 상태 확인
echo "Jenkins 설치 완료 및 서비스 상태:"
systemctl status jenkins

# 초기 비밀번호 확인 안내
echo "Jenkins 초기 비밀번호를 확인하려면 다음 명령을 사용하세요:"
echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```
## 1.2. 스크립트 실행
스크립트를 실행하여 Jenkins를 설치합니다.
```
]# ./install.sh

Last metadata expiration check: 2:10:31 ago on Thu 15 Aug 2024 09:53:31 AM KST.
Dependencies resolved.
Nothing to do.
Complete!
Last metadata expiration check: 2:10:32 ago on Thu 15 Aug 2024 09:53:31 AM KST.
Package java-17-openjdk-1:17.0.12.0.7-2.fc39.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
Adding repo from: https://pkg.jenkins.io/redhat-stable/jenkins.repo
Jenkins-stable                                                                                                                                                                                                                                                                                100 kB/s | 2.9 kB     00:00    
Dependencies resolved.
==============================================================================================================================================================================================================================================================================================================================
 Package                                                                      Architecture                                                                Version                                                                          Repository                                                                    Size
==============================================================================================================================================================================================================================================================================================================================
Installing:
 jenkins                                                                      noarch                                                                      2.462.1-1.1                                                                      jenkins                                                                       89 M

Transaction Summary
==============================================================================================================================================================================================================================================================================================================================
Install  1 Package

Total download size: 89 M
Installed size: 89 M
Downloading Packages:
[MIRROR] jenkins-2.462.1-1.1.noarch.rpm: Curl error (92): Stream error in the HTTP/2 framing layer for https://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/redhat-stable/jenkins-2.462.1-1.1.noarch.rpm [HTTP/2 stream 1 was not closed cleanly: PROTOCOL_ERROR (err 1)]                                                        
jenkins-2.462.1-1.1.noarch.rpm                                                                                                                                                                                                                                                                3.5 MB/s |  89 MB     00:25    
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                                                                                                                                         3.5 MB/s |  89 MB     00:25     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                                                                                                                                      1/1 
  Running scriptlet: jenkins-2.462.1-1.1.noarch                                                                                                                                                                                                                                                                           1/1 
  Installing       : jenkins-2.462.1-1.1.noarch                                                                                                                                                                                                                                                                           1/1 
  Running scriptlet: jenkins-2.462.1-1.1.noarch                                                                                                                                                                                                                                                                           1/1 
  Verifying        : jenkins-2.462.1-1.1.noarch                                                                                                                                                                                                                                                                           1/1 

Installed:
  jenkins-2.462.1-1.1.noarch                                                                                                                                                                                                                                                                                                  

Complete!
Created symlink /etc/systemd/system/multi-user.target.wants/jenkins.service → /etc/systemd/system/jenkins.service.
FirewallD is not running
FirewallD is not running
Jenkins 설치 완료 및 서비스 상태:
● jenkins.service - Jenkins Continuous Integration Server
     Loaded: loaded (/etc/systemd/system/jenkins.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: active (running) since Thu 2024-08-15 12:04:41 KST; 30s ago
   Main PID: 57725 (java)
      Tasks: 62 (limit: 11871)
     Memory: 917.9M
        CPU: 11.452s
     CGroup: /system.slice/jenkins.service
             └─57725 /usr/bin/java -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --webroot=/var/cache/jenkins/war --httpPort=8081

Aug 15 12:04:38 MW jenkins[57725]: 7f867bef359248829624784f3f99acd3 <-- 패스워드
Aug 15 12:04:38 MW jenkins[57725]: This may also be found at: /var/lib/jenkins/secrets/initialAdminPassword
Aug 15 12:04:38 MW jenkins[57725]: *************************************************************
Aug 15 12:04:38 MW jenkins[57725]: *************************************************************
Aug 15 12:04:38 MW jenkins[57725]: *************************************************************
Aug 15 12:04:41 MW jenkins[57725]: 2024-08-15 03:04:41.722+0000 [id=48]        INFO        jenkins.InitReactorRunner$1#onAttained: Completed initialization
Aug 15 12:04:41 MW jenkins[57725]: 2024-08-15 03:04:41.733+0000 [id=26]        INFO        hudson.lifecycle.Lifecycle#onReady: Jenkins is fully up and running
Aug 15 12:04:41 MW systemd[1]: Started jenkins.service - Jenkins Continuous Integration Server.
Aug 15 12:04:42 MW jenkins[57725]: 2024-08-15 03:04:42.520+0000 [id=67]        INFO        h.m.DownloadService$Downloadable#load: Obtained the updated data file for hudson.tasks.Maven.MavenInstaller
Aug 15 12:04:42 MW jenkins[57725]: 2024-08-15 03:04:42.520+0000 [id=67]        INFO        hudson.util.Retrier#start: Performed the action check updates server successfully at the attempt #1
Jenkins 초기 비밀번호를 확인하려면 다음 명령을 사용하세요:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
## 1.3. Jenkins 웹 인터페이스 접근
Jenkins가 설치된 후, 웹 브라우저에서 http://<YOUR_SERVER_IP>:8080으로 이동합니다. 초기 비밀번호는 스크립트가 전부 실행이 되면 위와 같이 패스워드가 표시가 됩니다.



# 2. Jenkins CI/CD 파이프라인 설정
이제 Jenkins를 사용하여 CI/CD 파이프라인을 설정합니다.

## 2.1. Dockerfile 및 Jenkinsfile 준비
Dockerfile

다음은 Apache Tomcat을 포함하는 Dockerfile의 예입니다. 이 파일은 `Dockerfile`로 저장됩니다.
```
# 베이스 이미지로 Tomcat 사용
FROM docker.io/library/tomcat

# 애플리케이션 파일을 Tomcat 웹앱 디렉토리로 복사
COPY SessionCookieApp-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/

# Tomcat 포트를 외부에 노출
EXPOSE 8080

# Tomcat을 실행
CMD ["catalina.sh", "run"]
```

Jenkinsfile

다음은 Jenkins 파이프라인을 설정하기 위한 Jenkinsfile의 예입니다. 이 파일은 프로젝트의 루트 디렉토리에 `Jenkinsfile`로 저장됩니다.
```
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sessioncookieapp:latest'
        CONTAINER_NAME = 'tomcat_sessioncookieapp'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://your_git_url'
            }
        }

        stage('Build Podman Image') {
            steps {
                script {
                    // Dockerfile을 사용하여 이미지를 빌드합니다.
                    sh 'podman build --no-cache -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // 기존 컨테이너가 있으면 종료 및 삭제
                    def containerExists = sh(script: "podman ps -aq -f name=${CONTAINER_NAME}", returnStdout: true).trim()
                    if (containerExists) {
                        sh "podman stop ${CONTAINER_NAME} || true"
                        sh "podman rm -f ${CONTAINER_NAME} || true"
                    }
                    
                    // 컨테이너를 실행
                    sh 'podman run -d --restart unless-stopped -p 8080:8080 --name ${CONTAINER_NAME} ${DOCKER_IMAGE}'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
            sh 'podman ps -a'
            sh 'podman images'
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed. Check the logs for details.'
            sh "podman logs ${CONTAINER_NAME}"
        }
    }
}

```

## 2.2. Jenkins 파이프라인 구성
#### 1. Jenkins 웹 인터페이스에 로그인: Jenkins 대시보드에서 "New Item"을 클릭하여 새로운 파이프라인을 생성합니다.
#### 2. 파이프라인 설정:
* `+ New Item` 클릭을 한다.
* `Item name` 지정 후 `Pipeline`을 클릭하여 OK를 누른다.
* 제일 아래에 `Pipeline script`를 설정해 준다. (위에 `Jenkinsfile` 사용 하시면 됩니다.)
* `save` 클릭
* `Build Now` 클릭 하면 아래에 `Build History`확인 가능

#### 3. Pipeline 정상 기동 확인
```
root@MW:/jenkins# podman ps -a
CONTAINER ID  IMAGE                              COMMAND          CREATED             STATUS             PORTS                   NAMES
956ad8a38630  localhost/sessioncookieapp:latest  catalina.sh run  About a minute ago  Up About a minute  0.0.0.0:8080->8080/tcp  tomcat_sessioncookieapp
root@MW:/jenkins# podman images
REPOSITORY                  TAG         IMAGE ID      CREATED             SIZE
localhost/sessioncookieapp  latest      59c666fdae7d  About a minute ago  475 MB
docker.io/library/tomcat    latest      087c6d900ed4  8 days ago          475 MB
```
