output "cluster_id" {
  value = data.digitalocean_kubernetes_cluster.primary.id
}

output "cluster_name" {
  value = data.digitalocean_kubernetes_cluster.primary.name
}