# Kubernetes ClickHouse server

Terraform module for creating simple ClickHouse server.

## Components

*ClickHouse* is an open source column-oriented database management system capable of real time generation of analytical data reports using SQL queries.

* Website: <https://clickhouse.yandex>
* Git repo: <https://github.com/yandex/ClickHouse.git>

*Clickhouse Exporter for Prometheus* is a simple server that periodically scrapes ClickHouse stats and exports them via HTTP for Prometheus consumption.

* Git repo: <https://github.com/f1yegor/clickhouse_exporter.git>

## Example usage

```HCL
module "clickhouse" {
  source    = "4ops/clickhouse-server/kubernetes"
  version   = "0.1.0"

  namespace = "testing"
}
```

See [example](https://github.com/4ops/terraform-kubernetes-clickhouse-server/tree/master/example) folder
