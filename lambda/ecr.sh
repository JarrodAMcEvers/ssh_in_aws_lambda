#! /bin/bash
AWS_DEFAULT_REGION=${1:-"us-east-1"}
export AWS_DEFAULT_REGION

TAG="latest"
IMAGE="ssh_lambda"
ACCOUNT_NUMBER=$(aws sts get-caller-identity | jq -r .Account)
ECR_URL="${ACCOUNT_NUMBER}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"

if ! aws ecr describe-repositories | jq --arg repo_name $IMAGE '.repositories[] | select(.repositoryName | contains($repo_name))' -e >> /dev/null; then
    echo "###############"
    echo "Creating ECR repo"
    echo "###############"
    aws ecr create-repository --repository-name $IMAGE
fi

if test ! -f git_lambda_layer.tar; then
    echo "###############"
    echo "Download git lambda layer"
    echo "###############"
    curl -s -w "Status code response: %{http_code}" $(aws lambda get-layer-version-by-arn --arn arn:aws:lambda:us-east-1:553035198032:layer:git-lambda2:8 | jq -r .Content.Location) -o git_lambda_layer.tar
fi

echo "###############"
echo "Building image"
echo "###############"
docker build -t $IMAGE:$TAG .
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
docker tag $IMAGE:$TAG $ECR_URL/${IMAGE}:$TAG
docker image push $ECR_URL/$IMAGE:$TAG
