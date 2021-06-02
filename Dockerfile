FROM ubuntu:focal-20210416
MAINTAINER liebestraum.tomo@gmail.com

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
    busybox-static \
    libsasl2-2 \
    libsasl2-dev \
    libsasl2-modules \
    postfix \
    sasl2-bin \
    supervisor \
    telnet \
    vim

# Python3
RUN apt-get install -y \
    python3-pip && \
    pip3 install boto3 && \
    rm -rf /var/lib/apt/lists/*

# Cron
COPY crontab_root /var/spool/cron/crontabs/root

# Supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Postfix
RUN postconf -F '*/*/chroot = n'
RUN postconf -e "maillog_file = /dev/stdout" && \
    postconf -e "smtpd_banner = ESMTP MTA" && \
    postconf -e "disable_vrfy_command = yes"

# Queue Monitoring for AWS CloudWatch
COPY put_metric.py /put_metric.py
RUN chmod 755 /put_metric.py

# Init
COPY init.sh /init.sh
RUN chmod 755 /init.sh
EXPOSE 25
CMD bash -c "/init.sh && /usr/bin/supervisord"
