terraform {
  required_version = "0.14.10"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.22.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  generation       = 2
  ibmcloud_timeout = var.ibmcloud_timeout
}

provider "kubernetes" {
  config_path = data.ibm_container_cluster_config.cluster.config_file_path
}
