output "ports" {
  value = [
    {
      name     = "http",
      protocol = "TCP",
      port     = var.http_port,
    },
    {
      name     = "native",
      protocol = "TCP",
      port     = var.native_port,
    },
    {
      name     = "metrics",
      protocol = "TCP",
      port     = var.metrics_port,
    }
  ]

  description = "Service ports list"
}
