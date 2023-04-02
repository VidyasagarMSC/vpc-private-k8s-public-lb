provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = var.ibmcloud_timeout
}

provider "kubernetes" {
  config_path = data.ibm_container_cluster_config.cluster.config_file_path
}
