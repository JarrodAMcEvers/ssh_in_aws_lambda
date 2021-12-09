resource "aws_security_group" "ssh_lambda" {
  name        = "ssh-lambdas"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "lambda_ssh_egress" {
  security_group_id = aws_security_group.ssh_lambda.id
  type              = "egress"
  description       = "SSH"
  to_port           = 22
  from_port         = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/32"]
}