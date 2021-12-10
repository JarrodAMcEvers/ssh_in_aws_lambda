#! /bin/bash
AWS_DEFAULT_REGION=${1:-"us-east-1"}
export AWS_DEFAULT_REGION

TAG="latest"
IMAGE="ssh_lambda"
ACCOUNT_NUMBER=$(aws sts get-caller-identity | jq -r .Account)
ECR_URL="${ACCOUNT_NUMBER}.dkr.ecr.${REGION}.amazonaws.com"

if test ! -f git_lambda_layer.tar; then
    curl -s -w "Status code response: %{http_code}" $(aws lambda get-layer-version-by-arn --arn arn:aws:lambda:us-east-1:553035198032:layer:git-lambda2:8 | jq -r .Content.Location) -o git_lambda_layer.tar
fi

docker build --no-cache -t $IMAGE:$TAG .
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
docker tag $IMAGE:$TAG $ECR_URL/${IMAGE}:$TAG
docker image push $ECR_URL/$IMAGE:$TAG
