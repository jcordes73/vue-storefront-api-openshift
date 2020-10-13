FROM registry.redhat.io/ubi8/nodejs-12

ENV VS_ENV=prod

WORKDIR /opt/app-root/src

COPY . .
COPY vue-storefront-api.sh /usr/local/bin/

RUN test -z "$NPM_MIRROR" || npm config set registry $NPM_MIRROR
RUN npm install --global yarn 
 && yarn install \
 && yarn build \
 && yarn cache clean

RUN chown -R 1001:0 /opt/app-root/src && chmod -R 777 /opt/app-root/src

EXPOSE 8080

USER 1001

CMD ["vue-storefront-api.sh"]
