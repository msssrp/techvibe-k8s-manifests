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
    name = "controller.nodeSelector.kubernetes\\.io/hostname"
    value = var.node_monitoring
  }

  set {
    name = "defaultBackend.nodeSelector.kubernetes\\.io/hostname"
    value = var.node_monitoring
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

  set {
    name = "server.nodeSelector.kubernetes\\.io/hostname"
    value = var.node_monitoring
  }

  set {
    name = "nodeSelector.kubernetes\\.io/hostname"
    value = var.node_monitoring
  }

  depends_on = [ helm_release.ingress-nginx ]
}

resource "helm_release" "grafana" {
  name = "grafana"

  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"

  namespace = "monitoring"
  create_namespace = true

  set {
    name = "nodeSelector.kubernetes\\.io/hostname"
    value = var.node_monitoring
  }

  depends_on = [ helm_release.ingress-nginx ]
}

data "template_file" "grafana-ingress_dns" {
  template = file("${path.module}/monitoring/grafana-ingress.yaml.tpl")
  vars = {
    dns_name = var.dns_name
  }
}

resource "kubectl_manifest" "grafana-ingress" {
  yaml_body = data.template_file.grafana-ingress_dns.rendered

  depends_on = [ helm_release.grafana]
}

data "template_file" "argocd-ingress_dns" {
  template = file("${path.module}/argocd/argocd-ingress.yaml.tpl")
  vars = {
    dns_name = var.dns_name
  }
}

resource "kubectl_manifest" "argocd-ingress" {
  yaml_body = data.template_file.argocd-ingress_dns.rendered

  depends_on = [  helm_release.argocd ]
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "7.3.11"

  namespace = "argocd"
  create_namespace = true
  
  set {
    name  = "global.nodeSelector.kubernetes\\.io/hostname"
    value = var.node_monitoring
  }

  depends_on = [ helm_release.ingress-nginx ]
}

resource "kubernetes_namespace" "jenkins-namespace" {
  metadata {
    annotations = {
      name = "jenkins"
    }
    labels = {
      name = "jenkins"
    }
    name = "jenkins"
  }
}

resource "kubernetes_manifest" "jenkins-presistent-volume" {
  manifest = file("${path.module}/jenkins-conf/jenkins-persistent-volume.yaml")

  depends_on = [ kubernetes_namespace.jenkins-namespace ]
}

resource "kubernetes_manifest" "jenkins-svc-account" {
  manifest = file("${path.module}/jenkins-conf/jenkins-service-account.yaml")

  depends_on = [ kubernetes_namespace.jenkins-namespace ]
}

data "template_file" "jenkins-deployment-nodeSelector" {
  template = file("${path.module}/jenkins-conf/jenkins-deployment.yaml.tpl")
  vars = {
    node = var.node_techvibe_jenkins
  }
}

resource "kubectl_manifest" "jenkins-deployment" {
  yaml_body = data.template_file.jenkins-deployment-nodeSelector.rendered

  depends_on = [ kubectl_manifest.jenkins-svc-account, kubectl_manifest.jenkins-presistent-volume ]
}


resource "kubectl_manifest" "jenkins-service" {
  yaml_body = file("${path.module}/jenkins-conf/jenkins-service.yaml")

  depends_on = [ kubectl_manifest.jenkins-deployment ]
}

data "template_file" "jenkins-ingress_dns" {
  template = file("${path.module}/jenkins-conf/jenkins-ingress.yaml.tpl")
  vars = {
    dns_name = var.dns_name
  }
}

resource "kubectl_manifest" "jenkins-ingress" {
  yaml_body = data.template_file.jenkins-ingress_dns.rendered

  depends_on = [ kubectl_manifest.jenkins-service ]
}