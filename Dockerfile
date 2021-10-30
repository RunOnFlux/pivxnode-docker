
ARG UBUNTUVER=20.04
FROM ubuntu:${UBUNTUVER}

RUN mkdir -p /root/.pivx
RUN apt-get update && apt-get install -y  tar wget curl pwgen jq
RUN wget https://github.com/PIVX-Project/PIVX/releases/download/v5.3.2.1/pivx-5.3.2.1-x86_64-linux-gnu.tar.gz -P /tmp
RUN tar xzvf /tmp/pivx-5.3.2.1-x86_64-linux-gnu.tar.gz -C /tmp \
&& cp /tmp/pivx-5.3.2.1/bin/* /usr/local/bin
RUN chmod 755 /tmp/pivx-5.3.2.1/install-params.sh
CMD ./tmp/pivx-5.3.2.1/install-params.sh
COPY node_initialize.sh /node_initialize.sh
COPY check-health.sh /check-health.sh
VOLUME /root/.pivx
RUN chmod 755 node_initialize.sh check-health.sh
EXPOSE 51472
HEALTHCHECK --start-period=5m --interval=2m --retries=5 --timeout=15s CMD ./check-health.sh
CMD ./node_initialize.sh
