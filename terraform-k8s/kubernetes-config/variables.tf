variable "cluster_name" {
  description = "value of the kubernetes cluster name"
  type = string
  default = "techvibe-k8s-d019e5b319"
}

variable "write_kubeconfig" {
  description = "value of the kubernetes cluster write kubeconfig"
  type = bool
  default = true
}

variable "do_token" {
  description = "value of the digitalocean token"
  type = string
}

variable "dns_name" {
  description = "value of the dns name"
  type = string
}

variable "node_monitoring" {
  description = "value of the node"
  type = string
  default = "cert-monitoring-node-wwxyo"
}

variable "node_techvibe_jenkins" {
  description = "value of the node"
  type = string
  default = "techvibe-jenkins-node-wwxbo"
}

variable "jenkins_admin_user" {
  type        = string
  description = "Admin user of the Jenkins Application."
  default     = "admin"
}

variable "jenkins_admin_password" {
  type        = string
  description = "Admin password of the Jenkins Application."
  default = "admin"
}