# Getting Started

### k8s
Deploy Loki, Prometheus and Grafana
```
kubectl apply -f observability-ns.yaml
kubectl apply -f Loki
kubectl apply -f Prometheus
kubectl apply -f Grafana
```

### Prometheus
Open local Prometheus in a browser

[http://PROMETHEUS_IP:9090](http://PROMETHEUS_IP:9090)

### Grafana
Open local Grafana in a browser

[http://GRAFANA_IP:3000](http://GRAFANA_IP:3000)