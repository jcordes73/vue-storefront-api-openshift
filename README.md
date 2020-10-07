# Vue Storefront API on OpenShift

## About

This project contains a version of the [Vue Storefront API](https://github.com/DivanteLtd/vue-storefront-api) deployable on [Red Hat OpenShift Container Platform](https://www.openshift.com/products/container-platform).

## Installation

The installation of the Vue Storefront API consists of the following parts

- Cloning of this repository
- Logging in into OpenShift as a developer and creation of a project
- Installing ElasticSearch 5.6
- Installing Redis 4
- Installing Vue Storefront API
- Adding labels/annotations for Topology View
- Install Magento 2

The installation of Red Hat OpenShift Container Platform is not part of this project. For a local deployment on your desktop/laptop consider using [Red Hat CodeReady Containers](https://developers.redhat.com/products/codeready-containers/overview).

### Cloning of the Vue Storefront API for OpenShift repository

	git clone https://github.com/jcordes73/vue-storefront-api-openshift
	cd vue-storefront-api-openshift

### Logging in into OpenShift and creation of a project

	oc login -u developer -p developer https://api.crc.testing:6443
	oc new-project vue-storefront

### Installing ElasticSearch 5.6

	oc new-app elasticsearch:5.6.11 --name elasticsearch -e discovery.type=single-node
	oc label deployment/elasticsearch app.openshift.io/runtime=elastic

### Installing Redis 4

	oc new-app redis:4 --name redis
	oc label deployment/redis app.openshift.io/runtime=redis

### Installing Vue Storefront API

	oc new-app https://github.com/jcordes73/vue-storefront-api-openshift --name vue-storefront-api --env-file=openshift.env
        oc expose svc vue-storefront-api

In case you want to adjust the configuration follow these steps

	oc create configmap vue-storefront-api --from-file=config
        oc set volumes deployments vue-storefront-api --add --overwrite=true --name=vue-storefront-api-config-volume --mount-path=/opt/app-root/src/config -t configmap --configmap-name=vue-storefront-api

To undo the configuration changes execute the following

	oc set volumes deployment vue-storefront-api --remove --name=vue-storefront-api-config-volume
	oc delete cm vue-storefront-api

### Adding labels/annotations for Topology View

	oc label deployment/vue-storefront-api app.openshift.io/runtime=nodejs
	oc annotate bc/vue-storefront-api app.openshift.io/vcs-uri="https://github.com/jcordes73/vue-storefront-api-openshift"
	oc annotate deployment/vue-storefront-api app.openshift.io/vcs-uri="https://github.com/jcordes73/vue-storefront-api-openshift"
	oc annotate deployment/vue-storefront-api app.openshift.io/connects-to=elasticsearch,redis

### Installing Magento

Installing Magento requires multiple steps:

- Installing MariaDB
- Installing the Magento 2 container

To deploy MariaDB 10.3 on execute the following

        oc new-app registry.redhat.io/rhel8/mariadb-103 --name mariadb -e MYSQL_DATABASE="bn_magento" -e MYSQL_USER="bn_magento" -e MYSQL_PASSWORD="pass"
        oc label deployment/mariadb app.openshift.io/runtime=mariadb

Now you can deploy the Magento 2 container

        oc new-app php:7.3~https://github.com/jcordes73/magento2#2.3 --name magento
        oc rsh deployments/magento magento setup:install --db-host mariadb --db-name bn_magento --db-user bn_magento --db-password pass --language=en_US --currency=USD --timezone=America/Chicago --use-rewrites=1
        oc rsh deployments/magento magento admin:user:create --admin-user=admin --admin-password='RedHat2020!' --admin-email="jcordes@redhat.com" --admin-firstname="Jochen" --admin-lastname="Cordes"
        oc label deployment/magento app.openshift.io/runtime=php
        oc annotate deployment/magento app.openshift.io/vcs-uri="https://github.com/jcordes73/magento2"
        oc annotate deployment magento app.openshift.io/connects-to=vue-storefront-api,mariadb
        oc expose svc magento

Login to Magento 2 with the admin user created at the path indicated by setup:install and create an integration (under "System" / "Integration"), modify the magento2 section in config/openshift.json to reflect the tokens and URLs.

## Next steps

Deploy [Vue Storefront for OpenShift](https://github.com/jcordes73/vue-storefront-openshift)
