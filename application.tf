resource "kubernetes_service_account" "application" {
  metadata {
    name      = var.application_name
    namespace = "default"
  }
}

resource "kubernetes_manifest" "service_application" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = var.application_name
      namespace = "default"
    }
    spec = {
      selector = {
        app = var.application_name
      }
      ports = [
        {
          port     = 8080
          protocol = "TCP"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "deployment_application" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      labels = {
        app = var.application_name
      }
      name      = var.application_name
      namespace = "default"
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = var.application_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.application_name
          }
          annotations = {
            "vault.hashicorp.com/auth-path"                                 = "auth/hashistack-${var.hashistack_sandbox_name}-config-kubernetes"
            "vault.hashicorp.com/agent-inject"                              = "true"
            "vault.hashicorp.com/agent-run-as-user"                         = 1000
            "vault.hashicorp.com/agent-run-as-group"                        = 3000
            "vault.hashicorp.com/agent-share-process-namespace"             = "true"
            "vault.hashicorp.com/role"                                      = "appkey-role"
            "vault.hashicorp.com/agent-inject-secret-config"                = "secrets/data/appkey"
            "vault.hashicorp.com/agent-inject-command-config"               = "kill -TERM $(pidof fake-service)"
            "vault.hashicorp.com/namespace"                                 = "admin"
            "vault.hashicorp.com/template-static-secret-render-interval"    = "30s"
            "vault.hashicorp.com/agent-inject-template-config"              = <<EOF
            {{- with secret "secrets/data/appkey" -}}
              export MESSAGE="Hello from the ${var.application_name} Service with APP Key of {{ .Data.data.foo }}!"
            {{- end }}
            EOF
            "consul.hashicorp.com/connect-inject"                           = "true"
            "consul.hashicorp.com/transparent-proxy-exclude-outbound-ports" = "8200"
          }
        }
        spec = {
          containers = [
            {
              env = [
                {
                  name  = "LISTEN_ADDR"
                  value = "0.0.0.0:8080"
                },
                {
                  name  = "NAME"
                  value = var.application_name
                }
              ]
              image = var.container_image
              name  = var.application_name
              ports = [
                {
                  containerPort = 8080
                },
              ]
              resources = {
                limits = {
                  cpu    = "500m"
                  memory = "512Mi"
                }
                requests = {
                  cpu    = "125m"
                  memory = "128Mi"
                }
              }
              command = ["sh", "-c"]
              args = [
                "source /vault/secrets/config && ${var.application_entrypoint}"
              ]
            },
          ]
          serviceAccountName = kubernetes_service_account.application.metadata[0].name
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "hpa_application" {
  metadata {
    name      = var.application_name
    namespace = "default"
  }
  spec {
    max_replicas = 5
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = var.application_name
    }
    target_cpu_utilization_percentage = 70
  }
}