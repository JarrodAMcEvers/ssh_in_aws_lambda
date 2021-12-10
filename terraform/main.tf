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
