provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# data "aws_sqs_queue" "pubsub" {
#   name = var.sqs_name
# }

# data "aws_sns_topic" "neworder" {
#   name = var.sns_name
# }

# resource "aws_sns_topic_subscription" "dapr_pubsub_sqs_target" {
#   topic_arn = aws_sns_topic.neworder.arn
#   protocol  = "sqs"
#   endpoint  = aws_sqs_queue.pubsub.arn
# }

resource "aws_sns_topic" "dapr_pubsub" {
  name = var.sns_name
}

resource "aws_sqs_queue" "dapr_pubsub_queue" {
  name = var.sqs_name
}

resource "aws_sns_topic_subscription" "dapr_pubsub_sqs_target" {
  topic_arn = aws_sns_topic.dapr_pubsub.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.dapr_pubsub_queue.arn
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
