# mashup prometheus grafana demo

## Background

This demo consists of two parts:
- Deploying the node-exporter Go binary to a host, scraping metrics with Prometheus, and visualising in Grafana
- Deploying a SpringBoot application that exposes a metrics endpoint, and visualising JVM metrics in Grafana

We will deploy Prometheus + Grafana on OpenShift before hand.

This repo consists of files to enable the demo:
- `prometheus.yml` config file, which can be converted into a ConfigMap
- script to patch the Prometheus deployment config
- submodule reference to `cat-metrics`, a simple SpringBoot application that exposes JVM metrics to Prometheus

## Demo setup

Note this demo requires a working Minishift environment.

Create all applications:
```
oc new-app grafana/grafana
oc expose svc/grafana

oc new-app prom/prometheus
oc expose svc/prometheus

oc new-app redhat-openjdk18-openshift:1.3~https://github.com/jockey10/cat-metrics.git
oc expose svc/cat-metrics 
```
Create a config map for Prometheus, and patch the DeploymentConfig:
```
oc create configmap electric-prom-config --from-file prometheus.yml
oc get dc/prometheus -o yaml > prom.yml
ruby prom_patcher.rb prom.yml
oc replace dc/prometheus -f prom.yml
```
Once all apps are re-deployed, login to Grafana with the creds admin/admin, and reset the password. Configure a datasource with the following values:
```
Name: prometheus
Type: Prometheus
URL: http://prometheus:9090
```
Select `Save & Test`

Import a new dashboard, and use the value `6756` (Spring Boot 2 statistics). Select the Prometheus data source as `prometheus. Select `Import`.

Import another dashboard, and use the value `1860` (node exporter full). Again, select the Prometheus data source as `prometheus`. Select `Import`.

## References

* [Openshift and Prometheus](https://www.robustperception.io/openshift-and-prometheus)
* [node_exporter](https://github.com/prometheus/node_exporter)
* [ansible-node-exporter](https://github.com/cloudalchemy/ansible-node-exporter)
