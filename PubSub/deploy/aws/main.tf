provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_sqs_queue" "aws_queue" {
  name = "app1"
}

resource "aws_sns_topic" "aws_notification" {
  name = "neworder"
}

resource "aws_dynamodb_table" "dapr_state_store" {
  name         = var.table_name
  billing_mode = var.table_billing_mode
  hash_key     = "key"
  attribute {
    name = "key"
    type = "S"
  }
  tags = {
    environment = "${var.environment}"
  }
}
