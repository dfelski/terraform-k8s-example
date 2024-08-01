terraform {
  # We need the kubernetes provider
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

# Provider configuration
provider "kubernetes" {
  # We'll use the local kube config file
  config_path = "~/.kube/config"
  # our k8s context name
  config_context = "minikube"
}

# Namespace 'bob' to separate our stuff from other things
resource "kubernetes_namespace" "bob" {
  metadata {
    name = "bob"
  }
}

# Nginx deployment
resource "kubernetes_deployment" "myapp" {
  metadata {
    name      = "myapp"
    namespace = kubernetes_namespace.bob.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Nginx service
resource "kubernetes_service" "myapp" {
  metadata {
    name      = "myapp"
    namespace = kubernetes_namespace.bob.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.myapp.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 8080
      target_port = 80
      protocol    = "TCP"
    }
    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "myapp" {
  wait_for_load_balancer = true
  metadata {
    name      = "myapp"
    namespace = kubernetes_namespace.bob.metadata.0.name
  }
  spec {
    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = kubernetes_service.myapp.metadata.0.name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

output "myapp_ip" {
  value = kubernetes_ingress_v1.myapp.status.0.load_balancer.0.ingress.0.ip
}
