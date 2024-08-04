resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "digitalocean-dns" {
  metadata {
    name      = "digitalocean-dns"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }

  data = {
    "access-token" = var.digitalocean_token
  }
  depends_on = [ kubernetes_namespace.cert-manager ]
}

module "cert_manager" {
  source        = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_email                   = "siripoom.dev@gmail.com"
  cluster_issuer_name                    = "letsencrypt-nginx-ingress"
  cluster_issuer_private_key_secret_name = "letsencrypt-nginx-private-key"
  namespace_name = kubernetes_namespace.cert-manager.metadata[0].name
  create_namespace = false

  solvers = [
    {
      dns01 = {
        digitalocean = {
          tokenSecretRef = {
            name = "digitalocean-dns"
            key = "access-token"
          }
        }
      },
      selector = {
        dnsZones = ["markcoding.online"]
      }
    }
  ]
  depends_on = [ kubernetes_secret.digitalocean-dns ]
}

resource "kubectl_manifest" "cert-manager-wildcard" {
    yaml_body = file("${path.module}/cert-manager/certificate-wildcard.yaml")

    depends_on = [ module.cert_manager , helm_release.reflector ]
}

resource "helm_release" "reflector" {
  name = "reflector"

  repository = "https://emberstack.github.io/helm-charts"
  chart = "reflector"

  namespace = kubernetes_namespace.cert-manager.metadata[0].name

  depends_on = [ module.cert_manager ]
}