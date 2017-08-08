FROM mono:4.6.1.3

ENV KLONDIKE_VERSION=v2.1.1
ENV KLONDIKE_BUILD=2.1.1.22ea5477-build156

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    wget unzip mono-4.0-service && \
    rm -rf /var/cache/apt/*

RUN mkdir /app && cd /app && wget https://github.com/themotleyfool/Klondike/releases/download/${KLONDIKE_VERSION}/Klondike.${KLONDIKE_BUILD}.zip -O /app/Klondike.${KLONDIKE_BUILD}.zip && \
    unzip *.zip

EXPOSE 8080

COPY Settings.config /app/Settings.config
COPY etc_ide.d /etc/ide.d

WORKDIR /app/bin
# https://github.com/themotleyfool/Klondike/issues/156#issuecomment-229798239
CMD ["mono-service", "Klondike.SelfHost.exe", "--no-daemon", "--port=8080"]
