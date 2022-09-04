provider "google" {
  project = "${var.project_id}"
  region  = "${var.region}"
}

resource "google_storage_bucket" "dapr_binding" {
  name          = var.bucket_name
  location      = "${var.location}"
  force_destroy = true
}
