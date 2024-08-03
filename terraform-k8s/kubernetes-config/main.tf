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
        dnsZones = ["techvibe.app"]
      }
    }
  ]
  depends_on = [ kubernetes_secret.digitalocean-dns ]
}
/*
resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx-controller"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  namespace = "ingress-nginx"
  create_namespace = true

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = format("%s-nginx-ingress", var.cluster_name)
  }
}



resource "helm_release" "reflector" {
  name = "reflector"

  repository = "https://emberstack.github.io/helm-charts"
  chart = "reflector"

  namespace = "cert-manager"
  create_namespace = true 

  depends_on = [ helm_release.cert-manager ]
}

resource "helm_release" "prometheus" {
  name = "prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"

  namespace = "monitoring"
  create_namespace = true

  depends_on = [ helm_release.cert-manager ]
}

resource "helm_release" "grafana" {
  name = "grafana"

  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"

  namespace = "monitoring"
  create_namespace = true

  values = [
    file("${path.module}/monitoring/grafana-ingress.yaml"),
  ]

  depends_on = [ helm_release.prometheus , helm_release.reflector ]
}*/