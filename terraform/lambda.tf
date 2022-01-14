data "aws_ecr_repository" "ssh_lambda" {
  name = "ssh_lambda"
}

data "aws_ecr_repository" "ssh_lambda_custom_os" {
  name = "ssh_lambda_custom_os"
}

data "aws_ecr_repository" "paramiko" {
  name = "paramiko"
}

data "aws_ecr_image" "ssh_lambda" {
  repository_name = data.aws_ecr_repository.ssh_lambda.name
  image_tag       = "latest"
}

data "aws_ecr_image" "ssh_lambda_custom_os" {
  repository_name = data.aws_ecr_repository.ssh_lambda_custom_os.name
  image_tag       = "latest"
}

data "aws_ecr_image" "paramiko" {
  repository_name = data.aws_ecr_repository.paramiko.name
  image_tag       = "latest"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/main.py"
  output_path = "../lambda/package.zip"
}
resource "aws_lambda_function" "default_ssh" {
  function_name    = "no_working_ssh"
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "main.handler"
  runtime          = "python3.9"
  source_code_hash = filesha256(data.archive_file.lambda_zip.output_path)
  role             = aws_iam_role.lambda.arn
  timeout          = 300
  memory_size      = 256

  vpc_config {
    security_group_ids = [aws_security_group.ssh_lambda.id]
    subnet_ids         = var.subnets
  }

  environment {
    variables = {
      SSH_KEY_SECRET_ID = aws_secretsmanager_secret.ssh_key.id
      REPO_TO_DOWNLOAD  = "git@github.com:JarrodAMcEvers/ssh_in_aws_lambda.git"
      GIT_SSH_COMMAND   = "ssh -o UserKnownHostsFile=/tmp/known_hosts -i /tmp/id_rsa"
      DEBUG_SSH         = "true"
    }
  }
}

resource "aws_lambda_function" "working_ssh" {
  function_name    = "working_ssh"
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "main.handler"
  runtime          = "python3.9"
  source_code_hash = filesha256(data.archive_file.lambda_zip.output_path)
  role             = aws_iam_role.lambda.arn
  timeout          = 300
  memory_size      = 256

  layers = ["arn:aws:lambda:us-east-1:553035198032:layer:git-lambda2:8"]

  vpc_config {
    security_group_ids = [aws_security_group.ssh_lambda.id]
    subnet_ids         = var.subnets
  }

  environment {
    variables = {
      SSH_KEY_SECRET_ID = aws_secretsmanager_secret.ssh_key.id
      REPO_TO_DOWNLOAD  = "git@github.com:JarrodAMcEvers/ssh_in_aws_lambda.git"
      GIT_SSH_COMMAND   = "ssh -o UserKnownHostsFile=/tmp/known_hosts -i /tmp/id_rsa"
    }
  }
}

resource "aws_lambda_function" "ssh_in_container" {
  function_name = "working_ssh_in_a_container"
  role          = aws_iam_role.lambda.arn
  image_uri     = "${data.aws_ecr_repository.ssh_lambda.repository_url}@${data.aws_ecr_image.ssh_lambda.image_digest}"
  package_type  = "Image"
  timeout       = 300
  memory_size   = 256

  vpc_config {
    security_group_ids = [aws_security_group.ssh_lambda.id]
    subnet_ids         = var.subnets
  }

  environment {
    variables = {
      REPO_TO_DOWNLOAD  = "git@github.com:JarrodAMcEvers/ssh_in_aws_lambda.git"
      SSH_KEY_SECRET_ID = aws_secretsmanager_secret.ssh_key.id
      GIT_SSH_COMMAND   = "ssh -o UserKnownHostsFile=/tmp/known_hosts -i /tmp/id_rsa"
    }
  }
}

resource "aws_lambda_function" "ssh_in_container_custom_os" {
  function_name = "working_ssh_in_a_custom_os_container"
  role          = aws_iam_role.lambda.arn
  image_uri     = "${data.aws_ecr_repository.ssh_lambda_custom_os.repository_url}@${data.aws_ecr_image.ssh_lambda_custom_os.image_digest}"
  package_type  = "Image"
  timeout       = 300
  memory_size   = 256

  vpc_config {
    security_group_ids = [aws_security_group.ssh_lambda.id]
    subnet_ids         = var.subnets
  }

  environment {
    variables = {
      REPO_TO_DOWNLOAD  = "git@github.com:JarrodAMcEvers/ssh_in_aws_lambda.git"
      SSH_KEY_SECRET_ID = aws_secretsmanager_secret.ssh_key.id
      GIT_SSH_COMMAND   = "ssh -o UserKnownHostsFile=/tmp/known_hosts -i /tmp/id_rsa"
    }
  }
}

resource "aws_lambda_function" "paramiko_container" {
  function_name = "paramiko_container"
  role          = aws_iam_role.lambda.arn
  image_uri     = "${data.aws_ecr_repository.paramiko.repository_url}@${data.aws_ecr_image.paramiko.image_digest}"
  package_type  = "Image"
  timeout       = 300
  memory_size   = 256

  vpc_config {
    security_group_ids = [aws_security_group.ssh_lambda.id]
    subnet_ids         = var.subnets
  }

  environment {
    variables = {
      IP_ADDRESS        = "172.30.193.168"
      PEM_KEY_SECRET_ID = aws_secretsmanager_secret.pem_key.id
      S3_BUCKET         = var.s3_bucket
      OBJECT_PATH       = var.object_path
    }
  }
}
