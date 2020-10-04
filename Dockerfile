FROM registry.redhat.io/ubi8/nodejs-12

ENV VS_ENV=prod

WORKDIR /opt/app-root/src

COPY . .

RUN npm install --global yarn \
  && yarn install \
  && yarn cache clean \
  && yarn build

COPY vue-storefront-api.sh /usr/local/bin/

RUN \
    chown -R 1001:0 /opt/app-root/src && \
    chgrp -R 0 /opt/app-root/src && \
    chmod -R g=u /opt/app-root/src

EXPOSE 3000

USER 1001

CMD ["vue-storefront-api.sh"]
