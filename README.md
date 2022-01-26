## Introduction
This repo has everything needed to deploy lambda functions (both container and serverless) that can use SSH to either clone a repo from Github or remote login to a host. There are a number of lambda functions that get created, this is to show different ways to get SSH working in a function.

List of AWS lambda functions that get created:   
1. A regular serverless function. This is to show what happens when you try to SSH without installing any packages.
1. Serverless function that uses a git lambda layer for SSH.
1. Container, using a base image from Amazon, that manually installs a git lambda layer.
1. Container, using a python buster OS image, that installs the runtime interface client (pip install awslambdaric) and a git lambda layer.
1. Container that uses paramiko, a pip package, to remotely login to a host. This lambda is not created by default.

## Requirements
1. Terraform CLI
1. AWS CLI
1. AWS credentials
1. Docker + CLI

## Quickstart to deploy the things
```bash
cd lambda
./ecr.sh
cd ../terraform
terraform apply -var-file <var_file>
```

Running `ecr.sh` is important as it creates the Elastic Container Registries (ECR), downloads the git lambda layer, and tags and pushes various docker images to the ECR repos.

You will need two variables in a variables file to deploy most of the resources to AWS: `vpc_id` and `subnets`.
```txt
# variables file
vpc_id = "vpc-xxxxxxxx"
subnets = [
  "subnet-a",
  "subnet-b"
]
```

## Additional steps after deploying
After creating the resources, you will need to manually update the secret value with the contents of a private key used for Github.

## Deploying lambda container that can remote login to a host
To deploy a lambda container capable of remote logging into a host, there are a few variables

Along with the `remote_ssh_lambda_enabled` var, you also need a few more things to get it to work properly.

Here are the additional variables needed:

1. `remote_ssh_lambda_enabled`
1. `remote_host_address`
1. `remote_user`
1. `s3_bucket`
1. `pem_key_path`

`remote_ssh_lambda_enabled` is a control flag that will deploy this lambda container if set to true (default is false).   
`s3_bucket` is the bucket where the pem key lives. **The terraform code does not create this bucket.**   
`pem_key_path` is the location of the file in the s3 bucket specified. **The terraform code does not create this file in the s3 bucket.**   
`remote_host_address` and `remote_user` are used for remoting into a host.

```txt
# variables file
vpc_id = "vpc-xxxxxxxx"
subnets = [
  "subnet-a",
  "subnet-b"
]

remote_ssh_lambda_enabled = true
s3_bucket = "my_cool_bucket"
pem_key_path = "pem.key"
remote_host_address = "1.1.1.1"
remote_user = "ubuntu"
```

### Notes about the git lambda layer
Here is a link to the Github page where you can find out more information about the lambda layer used in this project: https://github.com/lambci/git-lambda-layer 