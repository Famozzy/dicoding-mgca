resource "google_compute_health_check" "http_health_check" {
  name = "http-health-check"

  timeout_sec        = 5
  check_interval_sec = 5

  http_health_check {
    port = 80
  }
}

locals {
  regions = tolist(var.regions)
}

resource "google_compute_backend_service" "backend" {
  name                  = "backend-service"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.http_health_check.self_link]

  backend {
    # asia-southeast1 region
    group                 = google_compute_instance_group_manager.instances[local.regions[0]].instance_group
    balancing_mode        = "RATE"
    max_rate_per_instance = 50
  }

  backend {
    # europe-west1 region
    group                 = google_compute_instance_group_manager.instances[local.regions[1]].instance_group
    balancing_mode        = "RATE"
    max_rate_per_instance = 50
  }

  log_config {
    enable = true
  }
}

resource "google_compute_ssl_certificate" "ssl_cert" {
  name        = "ssl-cert"
  private_key = file("./private.key")
  certificate = file("./certificate.crt")
}

resource "google_compute_url_map" "https_lb" {
  name            = "https-lb"
  default_service = google_compute_backend_service.backend.self_link
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.https_lb.self_link
  ssl_certificates = [google_compute_ssl_certificate.ssl_cert.self_link]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name        = "https-forwarding-rule"
  ip_protocol = "TCP"
  port_range  = "443"
  target      = google_compute_target_https_proxy.https_proxy.self_link
}
