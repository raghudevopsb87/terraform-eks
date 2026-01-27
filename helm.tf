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
}

resource "helm_release" "prometheus-stack" {

  depends_on = [null_resource.kubeconfig]

  name       = "promstack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  values     = [file("prom-stack-values.yml")]

  set = [
    {
      name  = "grafana.enabled"
      value = false
    },
    {
      name  = "prometheus.ingress.enabled"
      value = true
    },
    {
      name  = "grafana.enabled"
      value = false
    },
  ]

}

resource "helm_release" "nginx-ingress" {

  depends_on = [null_resource.kubeconfig]

  name       = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

}


