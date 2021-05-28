FROM ubuntu:focal-20210416
MAINTAINER liebestraum.tomo@gmail.com

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
    supervisor postfix sasl2-bin libsasl2-modules libsasl2-2 libsasl2-dev \
    telnet && \
    rm -rf /var/lib/apt/lists/*

# Supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Postfix
RUN postconf -F '*/*/chroot = n'
RUN postconf -e "maillog_file = /dev/stdout"

# Init
COPY init.sh /init.sh
RUN chmod 755 /init.sh
EXPOSE 25
CMD bash -c "/init.sh && /usr/bin/supervisord"
