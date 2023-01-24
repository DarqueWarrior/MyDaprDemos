provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_secretsmanager_secret" "dapr_secrets" {
  name = var.secrets_manager_name

  tags = {
    Name        = "Dapr Secrets Manager"
    environment = "${var.environment}"
  }
}

resource "aws_secretsmanager_secret_version" "my_secret" {
  secret_id     = aws_secretsmanager_secret.dapr_secrets.id
  secret_string = "My_Secret_From_AWS_Secrets_Manager"
}