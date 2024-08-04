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

resource "helm_release" "prometheus" {
  name = "prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"

  namespace = "monitoring"
  create_namespace = true

  depends_on = [ helm_release.ingress-nginx ]
}

resource "helm_release" "grafana" {
  name = "grafana"

  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"

  namespace = "monitoring"
  create_namespace = true

  depends_on = [ helm_release.ingress-nginx ]
}

resource "kubectl_manifest" "grafana-ingress" {
  yaml_body = file("${path.module}/monitoring/grafana-ingress.yaml")

  depends_on = [ helm_release.grafana]
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "7.3.11"

  namespace = "argocd"
  create_namespace = true
  
  depends_on = [ helm_release.ingress-nginx ]
}

resource "kubectl_manifest" "argocd-ingress" {
  yaml_body = file("${path.module}/argocd/argocd-ingress.yaml")

  depends_on = [  helm_release.argocd ]
}