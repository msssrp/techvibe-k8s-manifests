variable "cluster_name" {
    description = "value of the kubernetes cluster name"
    type = string
}

variable "cluster_region" {
    type = string
    description = "value of the kubernetes cluster region"
    default = "sgp1"
}

variable "kubernetes_version" {
    type = string
    description = "value of the kubernetes cluster version"
    default = "1.30.2-do.0"
}

variable "do_token" {
    type = string
    description = "value of the digitalocean token"
}

variable "enabel_create_techvibe_node" {
  description = "value of the kubernetes cluster create techvibe node"
  type = bool
  default = false
}