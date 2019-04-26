FROM python:3.7-alpine as base

RUN set -x && apk add --no-cache --virtual .build-deps gcc make libffi-dev musl-dev libc6-compat openldap-dev krb5-dev \
  && pip3 install -U https://github.com/dmux/polemarch/archive/master.zip 

FROM python:3.7-alpine

COPY --from=base /root/.cache /root/.cache
COPY settings.ini /root/settings.ini.dist
COPY start.sh /start.sh
COPY supervisord.conf /etc/supervisord.conf

RUN set -x \
  && rm -rf /root/.cache \
  && apk add --update --no-cache curl build-base mariadb-client mariadb-dev git openssh-client sshpass libuuid mailcap dcron supervisor \
  && apk add --update --no-cache bash nodejs nodejs-npm \
  && pip3 install --upgrade pip \
  && pip3 install -U https://github.com/dmux/polemarch/archive/master.zip \
  && pip3 install mysqlclient boto3 azure awscli \
  && curl https://cli-assets.heroku.com/install.sh | sh \
  && mkdir -p /var/run/polemarch /data \
  && chmod +x /start.sh


VOLUME ["/data"]

EXPOSE 8080

ENTRYPOINT ["/start.sh"]
