FROM ubuntu:xenial

MAINTAINER NoLedge Tech Ltd <engineering@noledgetech.com>

RUN apt update && apt install -y \
    apt-transport-https \
    apt-utils \
    wget \
    unzip \
    openjdk-8-jdk-headless \
    openjdk-8-jre-headless

RUN wget \
    https://s3-eu-west-1.amazonaws.com/noledgetech-install-files/activeeon_enterprise-pca_server-trial-linux-x64-8.0.0.zip \
    -O /opt/activeeon_enterprise-pca_server-trial-linux-x64-8.0.0.zip && \
    unzip -o -X /opt/activeeon_enterprise-pca_server-trial-linux-x64-8.0.0.zip -d /opt/ && \
    rm -rf /opt/activeeon_enterprise-pca_server-trial-linux-x64-8.0.0.zip && \
    ln -s /opt/activeeon_enterprise-pca_server-trial-linux-x64-8.0.0 /opt/activeeon_proactive_server

RUN rm -rf /opt/activeeon_proactive_server/bin/config/* && \
    rm -rf /opt/activeeon_proactive_server/data/defaultuser/* && \
    mkdir /scripts

COPY ./src/activeeon_proactive_server_entrypoint.sh /scripts/

WORKDIR /opt/activeeon_proactive_server/

EXPOSE 8080

CMD [ /scripts/activeeon_proactive_server_entrypoint.sh ]
