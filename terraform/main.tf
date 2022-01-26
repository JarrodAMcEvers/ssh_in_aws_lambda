provider "aws" {
  region = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC to put lambda functions into."
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets to attach to lambda functions"
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket name where the pem key lives"
  default     = ""
}

variable "pem_key_path" {
  type        = string
  description = "Object path of pem key in the S3 bucket mentioned above"
  default     = ""
}

variable "remote_host_address" {
  type        = string
  description = "IP Address or A record pointing to remote host you want to ssh into"
  default     = ""
}

variable "remote_user" {
  type        = string
  description = "Username for remote_host_address variable"
  default     = "ec2-user"
}

variable "remote_ssh_lambda_enabled" {
  type        = bool
  default     = false
  description = "Control flag on whether to deploy lambda function that handles ssh"
}
