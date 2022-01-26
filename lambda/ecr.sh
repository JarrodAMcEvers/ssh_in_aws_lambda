#! /bin/bash
AWS_DEFAULT_REGION=${1:-"us-east-1"}
export AWS_DEFAULT_REGION

TAG="latest"
IMAGE="git_ssh_lambda"
CUSTOM_OS_IMAGE="git_ssh_lambda_custom_os"
PARAMIKO_IMAGE="paramiko_ssh_lambda"
ACCOUNT_NUMBER=$(aws sts get-caller-identity | jq -r .Account)
ECR_URL="${ACCOUNT_NUMBER}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"

function create_ecr_repo() {
    if ! aws ecr describe-repositories | jq --arg repo_name $1 '.repositories[] | select(.repositoryName | contains($repo_name))' -e >> /dev/null; then
        echo "####################################"
        echo "Creating $1 ECR repo"
        echo "####################################"
        aws ecr create-repository --repository-name $1
    fi
}

create_ecr_repo $IMAGE
create_ecr_repo $CUSTOM_OS_IMAGE
create_ecr_repo $PARAMIKO_IMAGE

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
docker build -t ${PARAMIKO_IMAGE}:${TAG} . --file Dockerfile_paramiko

aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL

echo "####################################"
echo "Tagging and pushing images"
echo "####################################"
docker tag ${IMAGE}:${TAG} ${ECR_URL}/${IMAGE}:${TAG}
docker image push ${ECR_URL}/${IMAGE}:${TAG}

docker tag ${CUSTOM_OS_IMAGE}:${TAG} ${ECR_URL}/${CUSTOM_OS_IMAGE}:${TAG}
docker image push ${ECR_URL}/${CUSTOM_OS_IMAGE}:${TAG}

docker tag ${PARAMIKO_IMAGE}:${TAG} ${ECR_URL}/${PARAMIKO_IMAGE}:${TAG}
docker image push ${ECR_URL}/${PARAMIKO_IMAGE}:${TAG}
