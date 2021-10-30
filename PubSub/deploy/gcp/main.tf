provider "google" {
 credentials = file("CREDENTIALS_FILE.json")
 project     = var.project
 region      = var.region
}

resource "google_pubsub_topic" "gcp_pubsub" {
  name = "neworder"
}