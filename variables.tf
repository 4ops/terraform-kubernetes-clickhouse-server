variable "name" {
  type        = string
  default     = "clickhouse"
  description = <<-DESCRIPTION
    Name of instance.
    Used as service name, configMap name, secret name etc.
  DESCRIPTION
}

variable "namespace" {
  type        = string
  description = <<-DESCRIPTION
    Namespace in kubernetes for deployment.
  DESCRIPTION
}

variable "http_port" {
  type        = number
  default     = 8123
  description = <<-DESCRIPTION
    The port for connecting to the server over HTTP(s).
    See docs at: https://clickhouse.yandex/docs/en/operations/server_settings/settings/#http-port-https-port
  DESCRIPTION
}

variable "ingress_hostname" {
  type        = string
  default     = ""
  description = <<-DESCRIPTION
    Hostname for ingress HTTP traffic.
    If empty, ingress will not be installed.
  DESCRIPTION
}

variable "native_port" {
  type        = number
  default     = 9000
  description = <<-DESCRIPTION
    Port for communicating with clients over the TCP protocol.
    See docs at: https://clickhouse.yandex/docs/en/operations/server_settings/settings/#server_settings-tcp_port
  DESCRIPTION
}

variable "metrics_port" {
  type        = number
  default     = 9116
  description = <<-DESCRIPTION
    Port for scraping prometheus metrics.
    See docs at: https://github.com/f1yegor/clickhouse_exporter
  DESCRIPTION
}

variable "storage_size" {
  type        = string
  default     = "10Gi"
  description = <<-DESCRIPTION
    Persistent volume size for store data.
  DESCRIPTION
}

variable "storage_class" {
  type        = string
  default     = "standard"
  description = <<-DESCRIPTION
    Kubernetes storage class name.
  DESCRIPTION
}

variable "image_tag" {
  type        = string
  default     = "yandex/clickhouse-server:19.11"
  description = <<-DESCRIPTION
    Docker image tag for running clickhouse application.
  DESCRIPTION
}

variable "requests_cpu" {
  type        = string
  default     = "1000m"
  description = <<-DESCRIPTION
    Count of millicpu to request in kubernetes cluster.
  DESCRIPTION
}

variable "requests_memory" {
  type        = string
  default     = "4Gi"
  description = <<-DESCRIPTION
    Size of memory to request in kubernetes cluster.
  DESCRIPTION
}

variable "limits_cpu" {
  type        = string
  default     = "1000m"
  description = <<-DESCRIPTION
    CPU limit in kubernetes cluster.
  DESCRIPTION
}

variable "limits_memory" {
  type        = string
  default     = "4Gi"
  description = <<-DESCRIPTION
    Memory limit in kubernetes cluster.
  DESCRIPTION
}

variable "keep_alive_timeout" {
  type        = number
  default     = 3
  description = <<-DESCRIPTION
    The number of seconds that ClickHouse waits for incoming requests before closing the connection. Defaults to 3 seconds.
    See docs at: https://clickhouse.yandex/docs/en/operations/server_settings/settings/#keep-alive-timeout
  DESCRIPTION
}

variable "max_concurrent_queries" {
  type        = number
  default     = 100
  description = <<-DESCRIPTION
    The maximum number of simultaneously processed requests.
    See docs at: https://clickhouse.yandex/docs/en/operations/server_settings/settings/#max-concurrent-queries
  DESCRIPTION
}

variable "max_connections" {
  type        = number
  default     = 4096
  description = <<-DESCRIPTION
    The maximum number of inbound connections.
    See docs at: https://clickhouse.yandex/docs/en/operations/server_settings/settings/#max-connections
  DESCRIPTION
}

variable "exporter_username" {
  type        = string
  default     = "exporter"
  description = <<-DESCRIPTION
    Username for metric exporter connections.
  DESCRIPTION
}

variable "default_password" {
  type        = string
  default     = ""
  description = <<-DESCRIPTION
    Password for default user.
    If empty, random password will be generated.
    Password saving in kubernetes secret.
  DESCRIPTION
}

variable "uncompressed_cache_size" {
  type        = number
  default     = 8589934592
  description = <<-DESCRIPTION
    Cache size (in bytes) for uncompressed data used by table engines from the MergeTree.
    See docs at: https://clickhouse.yandex/docs/en/operations/server_settings/settings/#server-settings-uncompressed_cache_size
  DESCRIPTION
}

variable "mark_cache_size" {
  type        = number
  default     = 5368709120
  description = <<-DESCRIPTION
    Approximate size (in bytes) of the cache of "marks" used by MergeTree.
    See docs at: https://clickhouse.yandex/docs/en/operations/server_settings/settings/#mark-cache-size
  DESCRIPTION
}

variable "clickhouse_users" {
  type        = list
  default = [
    # {
    #   name      = "myuser"
    #   password  = "pa$$w0Rd"
    #   read_only = false
    #   database  = "mydb"
    #   remote    = true
    # }
  ]
  description = <<-DESCRIPTION
    List of users to create in users config.
  DESCRIPTION
}
