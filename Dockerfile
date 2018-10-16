FROM anapsix/alpine-java:8

LABEL maintainer="byte@byteflux.net"

ENV JAR_FILE=server.jar \
    HEAP_SIZE=1G \
    SHUTDOWN_COMMAND=stop \
    LOG_FILE=logs/latest.log

RUN apk add --update screen && \
    adduser -D -h /data wrapper && \
    apk add --virtual .build-deps curl unzip && \
    curl -o yjp-linux.zip https://www.yourkit.com/download/YourKit-JavaProfiler-2017.02-b75.zip && \
    unzip yjp-linux -d /opt && \
    ln -s /opt/YourKit-JavaProfiler-* /opt/yjp && \
    rm yjp-linux.zip && \
    apk del .build-deps && \
    rm /var/cache/apk/*

USER wrapper
WORKDIR /data

COPY wrapper-exec /usr/bin/
COPY entrypoint.sh /

CMD ["/entrypoint.sh"]
