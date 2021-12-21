# ssh_in_aws_lambda
Deploy AWS lambda functions (container and serverless) that can use ssh.

## Deploy the things
```bash
cd lambda
./ecr.sh
cd ../terraform
terraform apply -var-file vars.tfvars
```
