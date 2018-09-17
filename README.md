# mashup prometheus grafana demo

## Background

This demo consists of two parts:
- Deploying the node-exporter Go binary to a host, scraping metrics with Prometheus, and visualising in Grafana
- Deploying a SpringBoot application that exposes a metrics endpoint, and visualising JVM metrics in Grafana

We will deploy Prometheus + Grafana on OpenShift before hand.

This repo consists of files to enable the demo:
- a `prometheus.yml` config file, which can be converted into a ConfigMap
- submodule reference to `cat-metrics`, a simple SpringBoot application that exposes JVM metrics to Prometheus

## References

* [Openshift and Prometheus](https://www.robustperception.io/openshift-and-prometheus)
* [node_exporter](https://github.com/prometheus/node_exporter)
* [ansible-node-exporter](https://github.com/cloudalchemy/ansible-node-exporter)
