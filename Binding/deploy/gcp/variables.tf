variable "project_id" {
  description = "Project Id"
}

variable "region" {
  description = "Resource region"
}

variable "location" {
  description = "Resource location"
}

variable "bucket_name" {
  description = "Storage bucket name"
  default     = "dapr-bucket"
}