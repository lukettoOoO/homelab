# Prometheus & Grafana

## `kube-prometheus-stack`
- This stack contains:
    - **Prometheus**: Database for time series; actively pulls every few seconds metrics offered by apps and clusters
    - **Grafana**: UI where dashboards and graphs can be built, live updated with the metrics
    - **Node Exporter**: A small agent with runs on the node and translates the CPU, RAM and disk consumption of the server in metrics readable by Prometheus
    - **Kube-State-Metrics**: A service which listens to API server and exposes the state of K8s objects (how many pods are `Running`, how many crashed, how many replicas, etc.)
    - **Alertmanager**: The notifying system (Discord, Slack, Email) when something breaks

- Installation and deployment:
```bash
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

kubectl get pods -n monitoring -w

kubectl get secret --namespace monitoring prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80 --address 0.0.0.0
```