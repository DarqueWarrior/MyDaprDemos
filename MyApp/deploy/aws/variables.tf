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

variable "sqs_name" {
  description = "SQS name (A queue name is case-sensitive and can have up to 80 characters. You can use alphanumeric characters, hyphens (-), and underscores ( _ ).)"
  default     = "myapp"
}

variable "sns_name" {
  description = "SNS name (space is not allowed)"
  default     = "new"
}

variable "table_name" {
  description = "Dynamodb table name (space is not allowed)"
  default     = "myapp_statestore"
}

variable "table_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity."
  default     = "PAY_PER_REQUEST"
}

variable "environment" {
  description = "Name of environment"
  default     = "codespace"
}
