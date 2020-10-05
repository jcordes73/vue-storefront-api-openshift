FROM registry.redhat.io/ubi8/nodejs-12

ENV VS_ENV=prod

WORKDIR /opt/app-root/src

USER 0
COPY . .
RUN \
    chown -R 1001:0 /opt/app-root/src && \
    chgrp -R 0 /opt/app-root/src && \
    chmod -R g=u /opt/app-root/src
USER 1001

RUN npm install --global yarn \
  && yarn install \
  && yarn cache clean \
  && yarn build

EXPOSE 8080

CMD ["/opt/app-root/src/vue-storefront-api.sh"]
