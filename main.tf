provider "kubernetes" {
  version = ">= 1.8"
}

provider "template" {
  version = ">= 2.1"
}

provider "random" {
  version = ">= 2.1"
}

resource "random_string" "exporter_password" {
  length = 36
}

resource "random_string" "default_password" {
  length = 36
}

locals {
  default_password = var.default_password == "" ? random_string.default_password.result : var.default_password
}

resource "kubernetes_secret" "clickhouse_secret" {
  metadata {
    labels = {
      app = "clickhouse"
    }

    name      = var.name
    namespace = var.namespace
  }

  data = {
    default_password  = local.default_password
    exporter_username = var.exporter_username
    exporter_password = random_string.exporter_password.result
  }
}

resource "kubernetes_config_map" "clickhouse_config" {
  metadata {
    labels = {
      app = "clickhouse"
    }

    name      = var.name
    namespace = var.namespace
  }

  data = {
    "config.xml"   = data.template_file.server_config.rendered
    "users.xml"    = data.template_file.users_config.rendered
  }
}

resource "kubernetes_service" "clickhouse_service" {
  metadata {
    labels = {
      app = "clickhouse"
    }

    name      = var.name
    namespace = var.namespace
  }

  spec {
    selector = {
      app         = "clickhouse"
      instance-id = var.name
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = var.http_port
      target_port = 8123
    }

    port {
      name        = "native"
      protocol    = "TCP"
      port        = var.native_port
      target_port = 9000
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = var.metrics_port
      target_port = 9116
    }

    type       = "ClusterIP"
    cluster_ip = "None"
  }
}

resource "kubernetes_stateful_set" "clickhouse_instance" {
  metadata {
    labels = {
      app     = "clickhouse"
      version = split(":", var.image_tag)[1]
    }

    name      = var.name
    namespace = var.namespace
  }

  spec {
    replicas               = 1
    revision_history_limit = 3

    selector {
      match_labels = {
        app         = "clickhouse"
        instance-id = var.name
      }
    }

    service_name = var.name

    template {
      metadata {
        labels = {
          app         = "clickhouse"
          version     = split(":", var.image_tag)[1]
          instance-id = var.name
        }

        annotations = {}
      }

      spec {
        termination_grace_period_seconds = 300

        # server

        container {
          name              = "clickhouse-server"
          image             = var.image_tag
          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              add = ["NET_ADMIN", "SYS_NICE"]
            }
          }

          port {
            name           = "http"
            protocol       = "TCP"
            container_port = 8123
          }

          port {
            name           = "native"
            protocol       = "TCP"
            container_port = 9000
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/clickhouse-server"
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/clickhouse"
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          resources {
            limits {
              cpu    = var.limits_cpu
              memory = var.limits_memory
            }

            requests {
              cpu    = var.requests_cpu
              memory = var.requests_memory
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8123
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

        }

        # exporter

        container {
          name              = "clickhouse-exporter"
          image             = "f1yegor/clickhouse-exporter"
          image_pull_policy = "IfNotPresent"

          args = [
            "-scrape_uri=http://localhost:8123/",
          ]

          env {
            name  = "CLICKHOUSE_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.clickhouse_secret.metadata.0.name
                key  = "exporter_username"
              }
            }
          }

          env {
            name  = "CLICKHOUSE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.clickhouse_secret.metadata.0.name
                key  = "exporter_password"
              }
            }
          }

          port {
            name           = "metrics"
            protocol       = "TCP"
            container_port = 9116
          }

          resources {
            limits {
              cpu    = "50m"
              memory = "50Mi"
            }

            requests {
              cpu    = "50m"
              memory = "50Mi"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 9116
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }

        # volumes

        volume {
          name = "tmp"
          empty_dir {}
        }

        volume {
          name = "config"

          config_map {
            name = var.name
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.storage_class

        resources {
          requests = {
            storage = var.storage_size
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "clickhouse_http" {
  count = var.ingress_hostname == "" ? 0 : 1

  metadata {
    labels = {
      app = "clickhouse"
    }

    name      = var.name
    namespace = var.namespace
  }

  spec {
    rule {
      host = var.ingress_hostname
      http {
        path {
          backend {
            service_name = var.name
            service_port = var.http_port
          }

          path = "/"
        }
      }
    }
  }
}
