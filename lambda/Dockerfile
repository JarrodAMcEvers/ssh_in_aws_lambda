FROM public.ecr.aws/lambda/python:3.9

# Install unzip for lambda layer
RUN yum upgrade -y \
    && yum install unzip -y

# Only needed for local testing purposes
RUN pip install boto3

# Copy lambda layer code
# Lambda layer needs to reside in the /opt directory
WORKDIR /opt
COPY git_lambda_layer.tar /opt/
RUN unzip git_lambda_layer.tar && rm git_lambda_layer.tar

# Copy function code
# LAMBDA_TASK_ROOT = /var/task
WORKDIR ${LAMBDA_TASK_ROOT}
COPY main.py .

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "main.handler" ]
