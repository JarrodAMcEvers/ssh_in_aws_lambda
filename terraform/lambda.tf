resource "aws_lambda_function" "default_ssh" {
  function_name = "no_working_ssh"
  role          = aws_iam_role.lambda.arn
  timeout       = 300
  memory_size   = 256

  vpc_config {
    security_group_ids = [aws_security_group.ssh_lambda.id]
    subnet_ids         = var.subnets
  }
}

resource "aws_lambda_function" "working_ssh" {
  function_name = "no_working_ssh"
  role          = aws_iam_role.lambda.arn
  timeout       = 300
  memory_size   = 256

  vpc_config {
    security_group_ids = [aws_security_group.ssh_lambda.id]
    subnet_ids         = var.subnets
  }

  variables = {
    REPO_TO_DOWNLOAD  = "git@github.com:JarrodAMcEvers/ssh_in_aws_lambda.git"
    SSH_KEY_SECRET_ID = aws_secretsmanager_secret.ssh_key.id
    GIT_SSH_COMMAND   = "ssh -o StrictHostKeyChecking=no -i /tmp/id_rsa"
  }
}

resource "aws_lambda_function" "ssh_in_container" {
  function_name = "working_ssh_in_a_container"
  role          = aws_iam_role.lambda.arn
  image_uri     = "TBD"
  package_type  = "Image"
  timeout       = 300
  memory_size   = 256
  layer         = ["arn:aws:lambda:<region>:553035198032:layer:git-lambda2:8"]

  vpc_config {
    security_group_ids = [aws_security_group.ssh_lambda.id]
    subnet_ids         = var.subnets
  }

  environment {
    variables = {
      REPO_TO_DOWNLOAD  = "git@github.com:JarrodAMcEvers/ssh_in_aws_lambda.git"
      SSH_KEY_SECRET_ID = aws_secretsmanager_secret.ssh_key.id
      # needed so that we can use the lambda layer ssh brought in
      GIT_SSH_COMMAND   = "/opt/bin/ssh -o StrictHostKeyChecking=no -i /tmp/id_rsa"
    }
  }
}