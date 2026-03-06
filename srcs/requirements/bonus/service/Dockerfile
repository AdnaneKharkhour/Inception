FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

COPY tools/setup-fb.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup-fb.sh

EXPOSE 8082

ENTRYPOINT [ "setup-fb.sh" ]

CMD ["filebrowser", "--address", "0.0.0.0", "--port", "8082", "--root", "/srv"]