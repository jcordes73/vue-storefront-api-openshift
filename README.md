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

	oc label bc/vue-storefront-api app.openshift.io/runtime=nodejs
	oc label deployment/vue-storefront-api app.openshift.io/runtime=nodejs
	oc annotate bc/vue-storefront-api app.openshift.io/vcs-uri="https://github.com/jcordes73/vue-storefront-api-openshift"
	oc annotate deployment/vue-storefront-api app.openshift.io/vcs-uri="https://github.com/jcordes73/vue-storefront-api-openshift"
	oc annotate deployment/vue-storefront-api app.openshift.io/connects-to=elasticsearch,redis

## Next steps

Deploy [Vue Storefront for OpenShift](https://github.com/jcordes73/vue-storefront-openshift)
