import os
import boto3

ID_RSA_PATH='/tmp/id_rsa'
REPO_URL=os.getenv('REPO_TO_DOWNLOAD')
REPO_PATH='/tmp/{}'.format(REPO_URL)

secretsmanager = boto3.client('secretsmanager')

def retrieve_and_save_ssh_key():
    key = secretsmanager.get_secret_value(SecretId=os.getenv('SSH_KEY_SECRET_ID'))['SecretString']

    with open(ID_RSA_PATH, 'w') as file:
        file.write(key)
        # without the newline, the private key will not be in the correct format
        file.write('\n')
    os.chmod(ID_RSA_PATH, 0o400)

def handler(event, context):
    # delete everything in /tmp
    # if the lambda is hot, the function will not be able to reuse it because of the permissions
    # plus, this gets rid of the cloned repo
    os.system('rm -rf /tmp/*')
    # this line will fail for the lambda function that has the default ssh
    os.system('ssh -vT git@github.com')

    retrieve_and_save_ssh_key()

    os.system('git clone {} {}'.format(REPO_URL, REPO_PATH))
    os.system('ls -la {}'.format(REPO_PATH))
