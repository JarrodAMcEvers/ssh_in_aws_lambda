# ssh_in_aws_lambda
Deploy AWS lambda functions (container and serverless) that can use ssh.

## Deploy the things
```bash
cd lambda
./ecr.sh
cd ../terraform
terraform apply -var-file vars.tfvars
```
You will need to supply your own `vars.tfvars` file. The only variables needed for the terraform is `vpc_id` and `subnets`.

Here is an example:
```txt
vpc_id = "vpc-xxxxxxxx"
subnets = [
  "subnet-a",
  "subnet-b"
]
```
