
variable "access_key" {
  description = "Access key to AWS console"
}

variable "secret_key" {
  description = "Secret key to AWS console"
}

variable "region" {
  description = "The region to use to create the resource"
  default     = "us-east-2"
}

variable "bucket_name" {
  description = "S3 bucket name (space is not allowed)"
  default     = "dapr-bucket"
}

variable "environment" {
  description = "Name of environment"
  default     = "codespace"
}
