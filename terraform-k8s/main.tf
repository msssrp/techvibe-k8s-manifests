resource "random_id" "cluster_name" {
  byte_length = 5
}

locals {
  cluster_name = "techvibe-k8s-${random_id.cluster_name.hex}"
}

module "setup-cluster" {
    source = "./setup-cluster"
    do_token = var.do_token
    cluster_name = local.cluster_name
    enabel_create_techvibe_node = false
}

module "setup-cert-manager" {
  source = "./setup-cert-manager"
  cluster_name = module.setup-cluster.cluster_name
  digitalocean_token = var.do_token
}

module "kubernetes-config" {
  source = "./kubernetes-config"
  cluster_id = module.setup-cert-manager.cluster_id
  cluster_name = module.setup-cert-manager.cluster_name
  digitalocean_token = var.do_token
}