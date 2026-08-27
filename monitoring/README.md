# Kubernetes Monitoring

This directory contains the observability documentation and configuration for the Cloud Platform project.

## Scope

The monitoring stack runs on AKS and provides visibility into:

- Kubernetes objects and workload state
- Node resource usage
- Pod CPU and memory usage
- Deployment availability
- Prometheus targets and Grafana dashboards

The stack is based on the `kube-prometheus-stack` Helm chart and includes Prometheus, Grafana, kube-state-metrics, and Node Exporter.

## Data flow

```text
AKS workloads and nodes
          |
          +--> kube-state-metrics (Kubernetes object state)
          +--> Node Exporter (node metrics)
          +--> Kubernetes metrics and application metrics
                                  |
                                  v
                              Prometheus
                                  |
                                  v
                               Grafana
                         dashboards and alerts
```

## Repository contents

| Path | Purpose |
| --- | --- |
| `values.yaml` | Custom Helm values; currently reserved for platform-specific settings |
| `dashboards/` | Exported Grafana dashboard JSON |
| `screenshots/` | Monitoring evidence and visual references |
| `README.md` | Setup, access, validation, and troubleshooting guide |

## Namespaces and release

- Namespace: `monitoring`
- Helm release: `monitoring`

Inspect the installed stack:

```bash
kubectl get all -n monitoring
kubectl get pods -n monitoring
helm list -n monitoring
helm get values monitoring -n monitoring
```

## Install or update

Add the Prometheus community repository if needed:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Install or update the stack with the repository values file:

```bash
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values monitoring/values.yaml \
  --wait
```

When running the command from inside this directory, use `--values values.yaml` instead.

Export the rendered manifest for review:

```bash
helm get manifest monitoring -n monitoring > monitoring-manifest.yaml
```

## Access Grafana

Forward the Grafana service to the local machine:

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Open `http://localhost:3000`. The port-forward process must remain running while Grafana is in use.

## Useful PromQL queries

Check whether Node Exporter targets are reachable:

```promql
up{job="node-exporter"}
```

List Kubernetes pod information:

```promql
kube_pod_info
```

Compare desired and available Deployment replicas:

```promql
kube_deployment_spec_replicas
kube_deployment_status_replicas_available
```

View CPU usage by pod:

```promql
sum by (pod) (
  rate(container_cpu_usage_seconds_total{
    container!="",
    container!="POD"
  }[5m])
)
```

View memory usage by pod:

```promql
sum by (pod) (
  container_memory_working_set_bytes{
    container!="",
    container!="POD"
  }
)
```

## Validate workload availability

The demo application runs in the `helm-test` namespace. To create a simple availability test, scale it down and observe the replica metrics:

```bash
kubectl scale deployment demo-app -n helm-test --replicas=0
kubectl scale deployment demo-app -n helm-test --replicas=1
```

With one desired and one available replica, the workload is healthy. A difference between desired and available replicas indicates degraded availability and can be used as the basis for an alert.

## Dashboards and alerting

The exported dashboard in `dashboards/` can be imported into another Grafana instance. Prometheus provides the query and alerting data; Grafana provides dashboard visualization and alert presentation.

Review the installed alert and rule resources with:

```bash
kubectl get prometheusrules -n monitoring
kubectl get alertmanager -n monitoring
```

## Troubleshooting

Check pod status and events:

```bash
kubectl get pods -n monitoring
kubectl describe pod <pod-name> -n monitoring
```

Check logs and services:

```bash
kubectl logs <pod-name> -n monitoring
kubectl get svc -n monitoring
```

In the Prometheus UI, inspect scrape targets and verify expected targets are `UP`. If Grafana is unavailable, confirm the Grafana pod and service exist before retrying the port-forward.

## Validation record

The monitoring setup has been validated by:

- Confirming monitoring pods are running
- Querying Node Exporter and Kubernetes object metrics
- Viewing metrics through Grafana
- Testing changes to application replica counts
- Observing workload availability through Prometheus and Grafana

## Next steps

- Centralized log aggregation with Loki
- Application-level metrics and instrumentation
- Distributed tracing
- Alert routing and notification channels
- Service-level objectives and production dashboards
