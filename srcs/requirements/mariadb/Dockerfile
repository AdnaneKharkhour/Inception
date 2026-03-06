FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/setup-db.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup-db.sh

EXPOSE 3306

ENTRYPOINT [ "setup-db.sh" ]

CMD [ "mysqld" , "--user=mysql" ]