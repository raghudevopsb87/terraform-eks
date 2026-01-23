provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "argocd" {

  depends_on = [null_resource.kubeconfig]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set = [
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
  ]
}

resource "helm_release" "prometheus-stack" {

  depends_on = [null_resource.kubeconfig]

  name       = "promstack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  values     = [file("prom-stack-values.yml")]

  set = [
    {
      name  = "prometheus.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "grafana.enabled"
      value = false
    }

  ]

}

resource "helm_release" "nginx-ingress" {

  depends_on = [null_resource.kubeconfig]

  name       = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

}



