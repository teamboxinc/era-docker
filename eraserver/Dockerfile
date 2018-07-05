# Version: 0.1
FROM ubuntu:xenial

ARG DB_HOST
ARG DB_PORT
ARG DB_ADMIN_USER
ARG DB_ADMIN_PASS
ARG DB_USER
ARG DB_PASS
ARG DB_DATABASE
ARG ERA_HOST_NAMES
ARG ERA_ADMIN_PASS

RUN echo "Asia/Tokyo" | tee /etc/timezone

RUN apt-get update && \
    apt-get install -y xvfb cifs-utils unixodbc openssl wget

ADD ./mysql-connector-odbc-5.3.10-linux-ubuntu16.04-x86-64bit/lib/libmyodbc5w.so /usr/lib/x86_64-linux-gnu/odbc/libmyodbc5w.so
ADD ./mysql-connector-odbc-5.3.10-linux-ubuntu16.04-x86-64bit/lib/libmyodbc5S.so /usr/lib/x86_64-linux-gnu/odbc/libmyodbc5S.so

RUN echo "[MySql]" > /etc/odbcinst.ini && \
    echo "Driver        = /usr/lib/x86_64-linux-gnu/odbc/libmyodbc5w.so" >> /etc/odbcinst.ini && \
    echo "Setup         = /usr/lib/x86_64-linux-gnu/odbc/libmyodbc5S.so" >> /etc/odbcinst.ini && \
    echo "FileUsage     = 1" >> /etc/odbcinst.ini

ADD ./Server-Linux-x86_64.sh /tmp/Server-Linux-x86_64.sh
RUN chmod +x /tmp/Server-Linux-x86_64.sh

# Trick for avoid installation failure: https://forum.eset.com/topic/14670-installation-issue-failed-to-connect-to-bus/
RUN mv /bin/systemctl /bin/systemctl.back

RUN echo "172.17.0.1 mysql" >> /etc/hosts && \
    /tmp/Server-Linux-x86_64.sh \
	--skip-license \
	--db-driver=MySQL \
	--db-type="MySQL Server" \
	--db-hostname=${DB_HOST} \
	--db-port=${DB_PORT} \
	--db-admin-username=${DB_ADMIN_USER} \
	--db-admin-password=${DB_ADMIN_PASS} \
	--db-user-username=${DB_USER} \
	--db-user-password=${DB_PASS} \
	--server-root-password=${ERA_ADMIN_PASS} \
	--cert-hostname=${ERA_HOST_NAMES} \
	--locale=ja-JP

RUN find /opt/eset/RemoteAdministrator/Server

RUN mv /bin/systemctl.back /bin/systemctl

CMD ["/opt/eset/RemoteAdministrator/Server/ERAServer"]
