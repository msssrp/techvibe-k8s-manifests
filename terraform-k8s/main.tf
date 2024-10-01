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
    kubernetes_version = "1.31.1-do.1"
    enabel_create_techvibe_node = true
}

module "setup-cert-manager" {
  source = "./setup-cert-manager"
  dns_name = "techvibe.app"
  cluster_name = module.setup-cluster.cluster_name
  do_token = var.do_token
}