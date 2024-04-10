FROM ubuntu:20.04

RUN apt update && apt install -y curl fuse && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

RUN set -x && \
    mkdir /juicefs && \
    cd /juicefs && \
    JFS_LATEST_TAG=$(curl -s https://api.github.com/repos/juicedata/juicefs/releases/latest | grep 'tag_name' | cut -d '"' -f 4 | tr -d 'v') && \
    curl -s -L "https://github.com/juicedata/juicefs/releases/download/v${JFS_LATEST_TAG}/juicefs-${JFS_LATEST_TAG}-linux-amd64.tar.gz" \
    | tar -zx && \
    install juicefs /usr/bin && \
    cd .. && \
    rm -rf /juicefs

ENV MINIO_ROOT_USER=admin
ENV MINIO_ROOT_PASSWORD=12345678
ENV REDIS_HOST=localhost
ENV REDIS_PORT=6379
ENV STORAGE=webdav
ENV ACCESS_KEY=accessKey
ENV SECRET_KEY=secretKey
ENV JSF_NAME=myjsf
ENV GATEWAY_PORT=9000
ENV META_PASSWORD=mypassword
ENV META_URL=postgres://user@192.168.1.6:5432/juicefs

# Expose Ports
EXPOSE 9000/tcp

CMD juicefs format --storage $STORAGE --bucket $BUCKET --access-key $ACCESS_KEY --secret-key $SECRET_KEY $META_URL $JSF_NAME;juicefs gateway $META_URL 0.0.0.0:$GATEWAY_PORT
