FROM alpine:3.20

RUN apk add --no-cache bash inotify-tools docker docker-compose jq && \
    apk --purge del

ADD entrypoint.sh /entrypoint.sh

WORKDIR /tmp

CMD ["/entrypoint.sh"]
