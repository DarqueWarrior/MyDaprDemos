provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_secretsmanager_secret" "dapr_secret" {
  name = var.secret_name
  tags = {
    environment = "${var.environment}"
  }
}

resource "aws_secretsmanager_secret_version" "new_secret_value" {
  secret_id     = aws_secretsmanager_secret.dapr_secret.id
  secret_string = "Dapr_Secret_From_AWS_Secrets_Manager"
}
