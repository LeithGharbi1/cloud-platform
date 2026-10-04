# Cloud Platform

An Internal Developer Platform (IDP) designed to simplify application deployment and lifecycle management on Azure.

## Architecture

- **Frontend:** React + TypeScript
- **Platform API:** Spring Boot + Java 21
- **Infrastructure:** Azure, AKS, ACR, Terraform
- **Deployment:** Helm + Azure DevOps CI/CD
- **Security:** Workload Identity Federation + Azure RBAC
- **Database:** PostgreSQL

## Platform Capabilities

- Application catalog based on Git repositories
- Self-service application deployment
- Application status and lifecycle management
- Kubernetes resource management
- Reproducible Azure infrastructure provisioning
- Identity-based cloud authentication

## Repository Structure

```text
apps/            # Applications
platform-api/    #platform backend
infrastructure/  # Terraform and Azure infrastructure
helm/             # Kubernetes deployment charts
monitoring/       # Platform monitoring