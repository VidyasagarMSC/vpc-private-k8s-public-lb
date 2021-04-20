output "cluster_name" {
  value = ibm_container_vpc_cluster.cluster.name
}

output "resource_group_id" {
  value = local.resource_group_id
}

output "region" {
  value = var.region
}

output "resource_group_name" {
  value = local.resource_group_name
}

output "registry_namespace" {
  value = local.registry_namespace_name
}

output "kubernetes_namespace" {
  value = local.kubernetes_namespace
}

output "loadbalancer_subnet_id" {
  value = ibm_is_subnet.subnet_lb.id
}