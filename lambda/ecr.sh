#! /bin/bash
AWS_DEFAULT_REGION=${1:-"us-east-1"}
export AWS_DEFAULT_REGION

TAG="latest"
IMAGE="ssh_lambda"
CUSTOM_OS_IMAGE="ssh_lambda_custom_os"
ACCOUNT_NUMBER=$(aws sts get-caller-identity | jq -r .Account)
ECR_URL="${ACCOUNT_NUMBER}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"

if ! aws ecr describe-repositories | jq --arg repo_name $IMAGE '.repositories[] | select(.repositoryName | contains($repo_name))' -e >> /dev/null; then
    echo "####################################"
    echo "Creating $IMAGE ECR repo"
    echo "####################################"
    aws ecr create-repository --repository-name $IMAGE
fi

if ! aws ecr describe-repositories | jq --arg repo_name $CUSTOM_OS_IMAGE '.repositories[] | select(.repositoryName | contains($repo_name))' -e >> /dev/null; then
    echo "####################################"
    echo "Creating $CUSTOM_OS_IMAGE ECR repo"
    echo "####################################"
    aws ecr create-repository --repository-name $CUSTOM_OS_IMAGE
fi

if test ! -f git_lambda_layer.tar; then
    echo "####################################"
    echo "Download git lambda layer"
    echo "####################################"
    curl -s -w "Status code response: %{http_code}" $(aws lambda get-layer-version-by-arn --arn arn:aws:lambda:us-east-1:553035198032:layer:git-lambda2:8 | jq -r .Content.Location) -o git_lambda_layer.tar
fi

echo "####################################"
echo "Building images"
echo "####################################"
docker build -t ${IMAGE}:${TAG} .
docker build -t ${CUSTOM_OS_IMAGE}:${TAG} . --file Dockerfile_custom_os

aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL

echo "####################################"
echo "Tagging and pushing images"
echo "####################################"
docker tag ${IMAGE}:${TAG} ${ECR_URL}/${IMAGE}:${TAG}
docker image push ${ECR_URL}/${IMAGE}:${TAG}

docker tag ${CUSTOM_OS_IMAGE}:${TAG} ${ECR_URL}/${CUSTOM_OS_IMAGE}:${TAG}
docker image push ${ECR_URL}/${CUSTOM_OS_IMAGE}:${TAG}

