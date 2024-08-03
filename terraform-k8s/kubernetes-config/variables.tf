variable "cluster_name" {
  description = "value of the kubernetes cluster name"
  type = string
}

variable "cluster_id" {
  description = "value of the kubernetes cluster id"
  type = string
}

variable "write_kubeconfig" {
  description = "value of the kubernetes cluster write kubeconfig"
  type = bool
  default = false
}

variable "digitalocean_token" {
  description = "value of the digitalocean token"
  type = string
}