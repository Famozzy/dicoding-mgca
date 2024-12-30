resource "google_compute_instance_template" "template" {
  for_each = toset(var.regions)

  name         = "template-${each.value}"
  region       = each.value
  machine_type = "e2-micro"
  tags         = ["http-server", "allow-ssh"]

  network_interface {
    subnetwork = google_compute_subnetwork.subnets[each.value].self_link
    access_config {
    }
  }

  disk {
    source_image = "debian-cloud/debian-12"
  }

  metadata = {
    startup-script-url = "gs://cloud-training/gcpnet/httplb/startup.sh"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "instances" {
  for_each = toset(var.regions)

  name               = "mig-${each.value}"
  base_instance_name = "mig-${each.value}"
  zone               = "${each.value}-b"
  target_size        = 1

  named_port {
    name = "http"
    port = 80
  }

  version {
    instance_template = google_compute_instance_template.template[each.value].self_link
  }
}

resource "google_compute_autoscaler" "autoscaler" {
  for_each = toset(var.regions)

  name   = "autoscaler-${each.value}"
  zone   = "${each.value}-b"
  target = google_compute_instance_group_manager.instances[each.value].self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 3
    cooldown_period = 45

    cpu_utilization {
      target = 0.8
    }
  }
}

