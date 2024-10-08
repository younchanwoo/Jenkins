# 베이스 이미지로 Tomcat 사용
FROM docker.io/library/tomcat

# 애플리케이션 파일을 Tomcat 웹앱 디렉토리로 복사
COPY SessionCookieApp-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/

# Tomcat 포트를 외부에 노출
EXPOSE 8080

# Tomcat을 실행
CMD ["catalina.sh", "run"]
