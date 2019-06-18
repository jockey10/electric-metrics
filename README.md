# electric-metrics prometheus grafana demo

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

Firstly, recursively clone this repo to collect all submodules:
```
git clone --recursive https://github.com/jockey10/electric-metrics.git
```

Create all applications:
```
oc new-app grafana/grafana
oc expose svc/grafana

oc new-app prom/prometheus
oc expose svc/prometheus

oc new-app java~https://github.com/shaneboulden/cat-metrics.git
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

Import a new dashboard, and use the value `6756` (Spring Boot 2 statistics). Select the Prometheus data source as `prometheus`. Select `Import`.

Deploy the node-exporter service to your local system:
```
ansible-playbook -i hosts deploy-node-exporter.yml --ask-become-pass
```
After the playbook has completed, verify that the node-exporter is up:
```
sudo systemctl status node_exporter

node_exporter.service - Prometheus Node Exporter
   Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2018-09-24 15:57:23 AEST; 6s ago
```

Import another dashboard into Grafana, and use the value `1860` (node exporter full). Again, select the Prometheus data source as `prometheus`. Select `Import`.

## References

* [Openshift and Prometheus](https://www.robustperception.io/openshift-and-prometheus)
* [node_exporter](https://github.com/prometheus/node_exporter)
* [ansible-node-exporter](https://github.com/cloudalchemy/ansible-node-exporter)
