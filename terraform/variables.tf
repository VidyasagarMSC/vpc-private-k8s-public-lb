variable "ibmcloud_api_key" {
  type      = string
  sensitive = true
}
variable "region" {
  type    = string
  default = "us-south"
}
variable "resource_group_name" {
  type    = string
  default = ""
}
variable "ibmcloud_timeout" {
  type    = number
  default = 600
}
variable "basename" { type = string }
variable "tags" {
  type    = list(string)
  default = ["terraform"]
}

variable "kubernetes_version" {
  type    = string
  default = "1.19"
}
variable "cluster_node_flavor" {
  type    = string
  default = "bx2.4x16"
}
variable "registry_namespace_name" {
  type        = string
  default     = ""
  description = "Name of the IBM Cloud Container registry namespace."
}

variable "kubernetes_namespace" {
  type        = string
  default     = ""
  description = "Kubernetes namespace."
}



