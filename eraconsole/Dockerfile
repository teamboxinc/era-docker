# Version: 0.1
FROM tomcat:9-jre8-alpine

COPY era.war /usr/local/tomcat/webapps/

COPY tomcat.sh /usr/local/bin
CMD  ["tomcat.sh", "run"]
