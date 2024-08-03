resource "digitalocean_kubernetes_cluster" "primary" {
  name = var.cluster_name
  region = var.cluster_region
  version = var.kubernetes_version

  node_pool {
    name = "cert-monitoring-node"
    size = "s-2vcpu-4gb"
    node_count = 1
  }
}

resource "digitalocean_kubernetes_node_pool" "techvibe-jenkins-node" {
  count = var.enabel_create_techvibe_node ? 1 : 0
  cluster_id = digitalocean_kubernetes_cluster.primary.id
  name = "techvibe-jenkins-node"
  size = "s-4vcpu-8gb"
  node_count = 1
}