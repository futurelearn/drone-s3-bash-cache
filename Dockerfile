FROM alpine:3.7

RUN apk add --no-cache bash sed tar python py-pip pigz && \
    pip install s3cmd && \
    apk --purge -v del py-pip

RUN mkdir /opt
WORKDIR /opt
COPY run.sh .
RUN chmod 755 run.sh

ENTRYPOINT ["/opt/run.sh"]
