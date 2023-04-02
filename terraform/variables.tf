variable "ibmcloud_api_key" {
  type        = string
  description = "The API key of the user deploying the solution"
  sensitive   = true
}
variable "region" {
  type        = string
  description = "Region in which you want to deploy. Run `ibmcloud regions`"
  default     = "us-south"
}
variable "resource_group_name" {
  type        = string
  description = "Provide a resource group name"
  default     = ""
}
variable "ibmcloud_timeout" {
  type        = number
  description = "IBM Cloud timeout value"
  default     = 600
}
variable "basename" {
  type        = string
  description = "A prefix attached to every resource"
}
variable "tags" {
  type        = list(string)
  description = "List of tags like dev, prod etc.,"
  default     = ["terraform"]
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the cluster, Run `ibmcloud ks versions`"
  default     = "1.21.9"
}
variable "cluster_node_flavor" {
  type        = string
  description = "Flavors determine how much virtual CPU, memory, and disk space is available to each worker node."
  default     = "bx2.4x16"
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



