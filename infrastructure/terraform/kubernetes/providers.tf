terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_kubernetes_cluster" "cloud_platform" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
}

provider "helm" {
  kubernetes = {
    host = data.azurerm_kubernetes_cluster.cloud_platform.kube_config[0].host

    cluster_ca_certificate = base64decode(
      data.azurerm_kubernetes_cluster.cloud_platform.kube_config[0].cluster_ca_certificate
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "kubelogin"

      args = [
        "get-token",
        "--login",
        "azurecli",
        "--server-id",
        "6dae42f8-4368-4678-94ff-3960e28e3630"
      ]
    }
  }
}