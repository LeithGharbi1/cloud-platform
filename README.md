# Cloud Platform

An Azure-based cloud platform for provisioning infrastructure, delivering containerized applications to AKS, and monitoring Kubernetes workloads.

The repository currently demonstrates an end-to-end DevOps workflow and is evolving toward an Internal Developer Platform (IDP) with developer self-service, stronger security, and production-oriented reliability.

## What is included

- Azure infrastructure provisioned with Terraform
- Configuration and environment automation with Ansible
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Docker and Helm
- Azure DevOps CI/CD
- Workload Identity Federation and Azure RBAC
- Prometheus and Grafana observability
- A containerized demo application

## Repository guide

| Path | Purpose |
| --- | --- |
| `infrastructure/terraform` | Azure resource definitions and outputs |
| `infrastructure/ansible` | Host and Kubernetes configuration automation |
| `apps/demo-app` | Demo application source and Dockerfile |
| `apps/demo-app-chart` | Helm chart for deploying the demo application |
| `monitoring` | Monitoring values, dashboard export, and monitoring guide |
| `azure-pipelines.yml` | Build, image publishing, and AKS deployment pipeline |

## Platform workflow

```text
Developer push
      |
      v
Azure DevOps pipeline
      |
      +--> Build Docker image --> Push image to ACR
      |
      +--> Authenticate to Azure --> Deploy Helm release to AKS
                                      |
                                      v
                               Running application
                                      |
                                      v
                             Prometheus --> Grafana
```

The pipeline tags each image with the Azure DevOps build ID. This makes every deployment traceable to one immutable image tag, for example `demo-app:123`.

## Azure architecture

```text
Resource group
  |
  +-- Virtual network (10.10.0.0/16)
  |     +-- AKS subnet
  |     +-- Pod CIDR (10.20.0.0/16)
  |     +-- Service CIDR (10.30.0.0/16)
  |
  +-- Azure Container Registry
  |
  +-- Azure Kubernetes Service
```

The development environment uses the following named resources:

- Resource group: `rg-cloud-platform-dev`
- AKS cluster: `aks-cloud-platform-dev`
- ACR login server: `acrcloudplatformdev01.azurecr.io`
- Application namespace: `helm-test`
- Monitoring namespace: `monitoring`

## Prerequisites

Install and authenticate the following tools before operating the platform:

- Azure CLI
- Terraform
- Ansible
- Docker
- kubectl
- Helm
- kubelogin when using Azure CLI authentication for AKS

You also need access to the Azure subscription, resource group, ACR, AKS cluster, and Azure DevOps service connection used by the pipeline.

## Provision infrastructure

Terraform manages the Azure resource layer:

```bash
cd infrastructure/terraform
terraform init
terraform validate
terraform plan
terraform apply
```

Review the plan before applying changes. Destroy the development environment only when it is no longer needed:

```bash
terraform destroy
```

Useful outputs include the resource group name, AKS cluster name, AKS FQDN, ACR name, and ACR login server.

## Configure hosts and Kubernetes

Ansible handles configuration after infrastructure is available. The main entry point is:

```bash
cd infrastructure/ansible
ansible-playbook playbooks/site.yml
```

Use the inventory and Ansible variables for the target environment. The roles cover common configuration, container runtime, Kubernetes, Helm, and platform services.

## Deploy the demo application

The Helm chart is located at `apps/demo-app-chart`. Deploy the current chart manually with:

```bash
helm upgrade --install demo-app apps/demo-app-chart \
  --namespace helm-test \
  --create-namespace
```

The default values use the image `acrcloudplatformdev01.azurecr.io/demo-app:latest`, expose a `ClusterIP` service on port 80, and enable an NGINX ingress for `demo.local`.

To deploy a specific image:

```bash
helm upgrade --install demo-app apps/demo-app-chart \
  --namespace helm-test \
  --create-namespace \
  --set image.repository=acrcloudplatformdev01.azurecr.io/demo-app \
  --set image.tag=123 \
  --wait
```

Check the result:

```bash
kubectl get pods -n helm-test
kubectl get deployments -n helm-test
kubectl get services -n helm-test
```

## CI/CD pipeline

The pipeline runs on pushes to `main` and has two stages:

1. **Build**: checks out the repository, builds `apps/demo-app`, and pushes the image to ACR using `$(Build.BuildId)` as the tag.
2. **Deploy**: obtains AKS credentials, converts the kubeconfig with `kubelogin`, verifies deployment permissions, and runs `helm upgrade --install` with the new image tag.

Azure authentication uses workload identity federation through the `cloud-platform-pipeline` service connection. The design avoids long-lived client secrets in the pipeline. Azure RBAC grants the identity only the access required for its operations.

## Operate AKS

```bash
az aks get-credentials \
  --resource-group rg-cloud-platform-dev \
  --name aks-cloud-platform-dev \
  --overwrite-existing

kubectl get nodes
kubectl get pods -A
kubectl get deployments -A
```

For application rollout details:

```bash
helm status demo-app -n helm-test
kubectl describe deployment demo-app -n helm-test
kubectl logs deployment/demo-app -n helm-test
```

## Monitoring

Prometheus, Grafana, kube-state-metrics, and Node Exporter provide cluster and workload visibility. The monitoring stack runs in the `monitoring` namespace. See [monitoring/README.md](monitoring/README.md) for installation, dashboard access, PromQL examples, and troubleshooting.

To open Grafana locally:

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
```

Then visit `http://localhost:3000` while the port-forward process is running.

## Security and platform boundaries

Terraform provisions resources, Ansible configures environments, Helm packages applications, and Azure DevOps delivers releases. Identity is handled through Microsoft Entra ID, workload identity federation, and Azure RBAC.

The platform is intended to grow toward:

- Azure Key Vault and secretless authentication
- Private endpoints and network segmentation
- Managed PostgreSQL, Redis, messaging, and object storage
- Application health checks, resource requests, and autoscaling
- Backups, disaster recovery, and service-level objectives

## Roadmap

| Phase | Status | Scope |
| --- | --- | --- |
| DevOps foundation | Complete | Git, Docker, Helm, Kubernetes, ACR, and CI/CD |
| Azure platform | Complete | Resource group, VNet, AKS, Terraform, RBAC, and federation |
| Observability | Complete | Prometheus, Grafana, exporters, PromQL, and workload checks |
| Developer platform | In progress | FastAPI, React, project submission, and deployment workflows |
| Production engineering | Planned | Managed services, Key Vault, private connectivity, and resilience |

## Further documentation

- [Monitoring guide](monitoring/README.md)
- [Terraform configuration](infrastructure/terraform)
- [Ansible automation](infrastructure/ansible)
- [Demo application chart](apps/demo-app-chart)
