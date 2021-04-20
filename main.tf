resource "ibm_resource_group" "group" {
  count = var.resource_group_name != "" ? 0 : 1
  name  = "${var.basename}-group"
  tags  = var.tags
}

data "ibm_resource_group" "group" {
  count = var.resource_group_name != "" ? 1 : 0
  name  = var.resource_group_name
}

resource "ibm_is_vpc" "vpc" {
  name           = "${var.basename}-vpc"
  resource_group = local.resource_group_id
}

resource "ibm_is_public_gateway" "gateway" {
  name = "${var.basename}-gateway"
  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.region}-3"

  //User can configure timeouts
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_subnet" "subnet" {
  count                    = 2
  name                     = "${var.basename}-subnet-${count.index + 1}"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = local.resource_group_id
  zone                     = "${var.region}-${count.index + 1}"
  total_ipv4_address_count = 256
}

resource "ibm_is_subnet" "subnet_lb" {
  name                     = "${var.basename}-subnet-lb"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = local.resource_group_id
  zone                     = "${var.region}-3"
  total_ipv4_address_count = 256
  public_gateway           = ibm_is_public_gateway.gateway.id
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${var.basename}-cluster"
  vpc_id            = ibm_is_vpc.vpc.id
  flavor            = var.cluster_node_flavor
  worker_count      = 1
  resource_group_id = local.resource_group_id
  kube_version      = var.kubernetes_version

  zones {
    subnet_id = ibm_is_subnet.subnet.0.id
    name      = "${var.region}-1"
  }
}

resource "ibm_container_vpc_worker_pool" "cluster_pool" {
  cluster           = ibm_container_vpc_cluster.cluster.id
  worker_pool_name  = "${var.basename}-wp"
  flavor            = var.cluster_node_flavor
  vpc_id            = ibm_is_vpc.vpc.id
  worker_count      = 1
  resource_group_id = local.resource_group_id
  zones {
    name      = "${var.region}-2"
    subnet_id = ibm_is_subnet.subnet.1.id
  }
}

data "ibm_container_cluster_config" "cluster" {
  cluster_name_id = ibm_container_vpc_cluster.cluster.id
  depends_on = [
    ibm_container_vpc_cluster.cluster
  ]
}

resource "kubernetes_namespace" "namespace" {
  count = var.kubernetes_namespace != "" ? 0 : 1
  metadata {
    name = "${var.basename}-namespace"
  }
  depends_on = [
    data.ibm_container_cluster_config.cluster
  ]
}

data "kubernetes_namespace" "namespace" {
  count = var.kubernetes_namespace != "" ? 1 : 0
  metadata {
    name = var.kubernetes_namespace
  }
  depends_on = [
    data.ibm_container_cluster_config.cluster
  ]
}

resource "ibm_cr_namespace" "namespace" {
  count             = var.registry_namespace_name != "" ? 0 : 1
  name              = "${var.basename}-cr-namespace"
  resource_group_id = local.resource_group_id
}

locals {
  resource_group_id       = var.resource_group_name != "" ? data.ibm_resource_group.group.0.id : ibm_resource_group.group.0.id
  resource_group_name     = var.resource_group_name != "" ? data.ibm_resource_group.group.0.name : ibm_resource_group.group.0.name
  registry_namespace_name = var.registry_namespace_name != "" ? var.registry_namespace_name : ibm_cr_namespace.namespace.0.name
  kubernetes_namespace    = var.kubernetes_namespace != "" ? data.kubernetes_namespace.namespace.0.metadata[0].name : kubernetes_namespace.namespace.0.metadata[0].name
}