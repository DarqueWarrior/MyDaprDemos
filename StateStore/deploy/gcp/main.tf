provider "google" {
  project = "${var.project_id}"
  region  = "${var.region}"
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = "${var.region}"
  database_type = "CLOUD_DATASTORE_COMPATIBILITY"
}