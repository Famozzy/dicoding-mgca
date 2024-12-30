resource "google_compute_network" "vpc" {
  name                    = "vpc-net"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnets" {
  for_each = toset(var.regions)

  region        = each.value
  name          = "subnet-${each.value}"
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = "192.168.${index(var.regions, each.value) + 1}.0/24"
}

resource "google_compute_firewall" "firewalls" {
  for_each = {
    "allow-ssh" = {
      allow_ports   = ["22"]
      target_tags   = ["allow-ssh"]
      source_ranges = ["0.0.0.0/0"]
    }
    "allow-http" = {
      allow_ports   = ["80"]
      target_tags   = ["http-server"]
      source_ranges = ["0.0.0.0/0"]
    }
    "allow-health-check" = {
      allow_ports   = []
      target_tags   = ["http-server"]
      source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
    }
  }

  name          = each.key
  target_tags   = each.value.target_tags
  source_ranges = each.value.source_ranges
  network       = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = each.value.allow_ports
  }
}