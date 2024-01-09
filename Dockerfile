
ARG UBUNTUVER=20.04
FROM ubuntu:${UBUNTUVER}
LABEL com.centurylinklabs.watchtower.enable="true"
ENV VERSION="5.5.0"
RUN mkdir -p /root/.pivx
RUN apt-get update && apt-get install -y  tar wget curl pwgen jq
RUN wget https://github.com/PIVX-Project/PIVX/releases/download/v${VERSION}/pivx-${VERSION}-x86_64-linux-gnu.tar.gz -P /tmp
RUN cd /tmp && tar -C /usr/local/bin --strip 1 -xf /tmp/pivx-${VERSION}-x86_64-linux-gnu.tar.gz \
&& cp /usr/local/bin/bin/* /usr/local/bin
COPY node_initialize.sh /node_initialize.sh
COPY check-health.sh /check-health.sh
COPY key.sh /key.sh
VOLUME /root/.pivx
RUN chmod 755 node_initialize.sh check-health.sh key.sh
EXPOSE 51472
HEALTHCHECK --start-period=5m --interval=2m --retries=5 --timeout=15s CMD ./check-health.sh
CMD ./node_initialize.sh
