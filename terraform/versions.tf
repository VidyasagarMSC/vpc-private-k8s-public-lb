terraform {
  required_version = ">= 1.0.7"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">= 1.49.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
