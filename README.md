# Jenkins 설치 가이드 for Fedora 39 with Java 17

이 문서는 Fedora 39에서 Java 17을 사용하여 Jenkins를 설치하는 간단한 가이드입니다.

1. Java 17 설치

Jenkins는 Java 17을 필요로 합니다. Fedora에서는 OpenJDK를 사용할 수 있습니다.

```
]# dnf install java-17-openjdk
```

2. Jenkins Repository 추가

Jenkins RPM 저장소를 추가합니다.

```
]# dnf install -y wget
]# wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat-stable/jenkins.repo
]# rpm --import http://pkg.jenkins.io/redhat-stable/jenkins.io.key
```

3. Jenkins 설치

Jenkins를 설치합니다.

```
]# dnf install jenkins
```

4. Jenkins 서비스 시작 및 활성화

Jenkins 서비스를 시작하고 부팅 시 자동으로 시작되도록 설정합니다.

```
]# systemctl enable --now jenkins
```

5. 방화벽 설정
   
Jenkins 포트(기본값 8080)를 방화벽에서 열어줍니다.

```
]# firewall-cmd --zone=public --add-port=8080/tcp --permanent
]# firewall-cmd --reload
```

6. Jenkins 초기 비밀번호 확인

Jenkins 초기 설정을 위해 관리자 비밀번호가 필요합니다.

```
]# cat /var/lib/jenkins/secrets/initialAdminPassword
571522a19b4043a6a7e23f031dd0b19f
```
위 명령을 실행하면 출력된 비밀번호를 복사합니다.

7. Jenkins 웹 인터페이스에서 설정

웹 브라우저에서 http://your_server_ip:8080로 이동하여 Jenkins 초기 설정을 완료합니다. 초기 비밀번호를 입력한 후, 플러그인 설치 및 관리자 계정 생성을 마칩니다.

8. Jenkins 플러그인 설치

Jenkins 대시보드에서 "Manage Jenkins" > "Manage Plugins"로 이동하여 필요한 플러그인을 설치합니다.

9. 로그 보는 방법

```
]# journalctl -xeu jenkins.service
```

10. script 실행으로 설치가능합니다.
```
## 기동
]# ./install.sh

## 삭제
]# remove.sh
```
