output "https_lb_url" {
  value = "https://${google_compute_global_forwarding_rule.https_forwarding_rule.ip_address}"
}

output "http_lb_url" {
  value = "http://${google_compute_global_forwarding_rule.http_forwarding_rule.ip_address}"
}
