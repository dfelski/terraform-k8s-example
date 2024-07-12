terraform {
  # We need the kubernetes provider
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
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
resource "kubernetes_deployment" "nginx" {
    metadata {
        name = "nginx"
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
                    name = "nginx"
                    port {
                        container_port = 80
                    }
                }
            }
        }
    }
}

# Nginx service
resource "kubernetes_service_v1" "nginx" {
    metadata {
        name = "nginx"
        namespace = kubernetes_namespace.bob.metadata.0.name
    }
    spec {
        selector = {
            app = kubernetes_deployment.nginx.spec.0.template.0.metadata.0.labels.app
        }
        port {
            port = 80
        }
    }
}