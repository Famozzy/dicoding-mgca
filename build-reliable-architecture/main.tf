provider "google" {
  project = var.project_id
}

resource "google_project_iam_member" "reviewer" {
  for_each = toset([
    "roles/compute.viewer",
    "roles/monitoring.viewer",
  ])

  project = var.project_id
  role    = each.value
  member  = "group:reviewer_googlecloud@dicoding.com"
}

resource "google_monitoring_dashboard" "dashboard" {
  dashboard_json = file("./dashboard.json")
}
