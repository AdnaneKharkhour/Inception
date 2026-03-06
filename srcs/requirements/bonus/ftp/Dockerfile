FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/ftp \
    mkdir -p /var/run/vsftpd/empty && \
    chmod 755 /var/run/vsftpd/empty && \
    chown root:root /var/run/vsftpd/empty
    
COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY tools/setup-ftp.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup-ftp.sh

EXPOSE 21 20000-20010

ENTRYPOINT ["setup-ftp.sh"]

CMD ["vsftpd", "/etc/vsftpd.conf"]