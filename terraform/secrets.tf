resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
  number  = true
  lower   = true
}

resource "aws_secretsmanager_secret" "ssh_key" {
  name = "github-ssh-key-${random_string.random.result}"
  description = "Private ssh key"
}

resource "aws_secretsmanager_secret_version" "ssh_value" {
  secret_id     = aws_secretsmanager_secret.ssh_key.id
  secret_string = "Change me!"

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}