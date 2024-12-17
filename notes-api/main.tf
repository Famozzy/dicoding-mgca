provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "services" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "container.googleapis.com"
  ])

  service = each.value
}

resource "google_service_account" "gke_sa" {
  account_id   = "gke-sa"
  display_name = "GKE Service Account"
}

resource "google_project_iam_member" "gke_sa" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

resource "google_project_iam_member" "reviewer" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/container.viewer",
  ])

  project = var.project_id
  role    = each.value
  member  = "group:reviewer_googlecloud@dicoding.com"
}


resource "google_artifact_registry_repository" "repo" {
  repository_id = "repo"
  location      = var.region
  format        = "DOCKER"

  depends_on = [google_project_service.services["artifactregistry.googleapis.com"]]
}

resource "google_container_cluster" "kube" {
  name     = "kube-cluster"
  location = var.zone

  initial_node_count       = 1
  remove_default_node_pool = true
  deletion_protection      = false

  depends_on = [google_project_service.services["container.googleapis.com"]]
}

resource "google_container_node_pool" "np" {
  name       = "kube-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.kube.id
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-micro"
    disk_type    = "pd-standard"
    disk_size_gb = 10

    service_account = google_service_account.gke_sa.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
