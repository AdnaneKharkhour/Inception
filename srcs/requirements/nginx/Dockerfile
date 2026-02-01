FROM alpine:3.23

RUN apt-get update && apt-get install -y \
    nginx \
    openssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=MA/ST=Tanger-Tetouan/L=Martil/O=42/CN=akharkho.42.fr"

COPY conf/nginx.conf etc/nginx/nginx.conf

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]
