# Kubernetes Package Manager (Helm)

- Installing Helm:
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

- Installing a Kubernetes repository:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm search repo prometheus
```

- Package store: https://artifacthub.io

| Concept | Meaning | Analogy with Linux |
| --- | --- | --- |
| Helm Chart | A package containing all the YAML templates for an application. | A .deb or .rpm package. |
| Helm Repository | A public or private server/store where you can download pre-made Charts created by the community or your team. | An apt repository (/etc/apt/sources.list). |
| Release | An actual instance of a Chart deployed and running inside your Kubernetes cluster. | An installed application/program on your system. |
| values.yaml | Your custom configuration file where you override specific parameters (e.g., changing the default Grafana password). | Configuration files located in /etc/. |