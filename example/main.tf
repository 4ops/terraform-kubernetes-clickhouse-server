terraform {
  required_version = "~> 0.12.1"
}

module "clickhouse" {
  source    = "../../terraform-kubernetes-clickhouse-server"
  name      = "testdb"
  namespace = "testing"

  clickhouse_users = [
    {
      name      = "test"
      password  = "test"
      read_only = false
      database  = "test"
      remote    = true
    },
    {
      name      = "another_user"
      password  = "wiTh_SuppppperP@$$w0rd"
      read_only = false
      database  = "production_data"
      remote    = false
    }
  ]

  exporter_username      = "exporter-32176"
  default_password       = "kjxalms.,maNvjwheuyhqw3"

  max_connections        = 42
  max_concurrent_queries = 11
  keep_alive_timeout     = 6

  # ... more in variables.tf
}
