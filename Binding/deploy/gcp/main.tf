provider "google" {
  project = "mydaprdemos-330800"
  region  = "us-central1"
}

resource "google_storage_bucket" "dapr_binding" {
  name          = var.bucket_name
  location      = "US"
  force_destroy = true
}
