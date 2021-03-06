resource "google_service_account" "gce_sa_rke_demo" {
  account_id   = "gce-rke-demo"
  display_name = "Terraform - GCE service account for RKE"
}

resource "google_project_iam_member" "gce_sa_rke_demo_compute_admin" {
  project = var.project
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.gce_sa_rke_demo.email}"
}
