import os
import boto3

ID_RSA_PATH='/tmp/id_rsa'
REPO_URL=os.getenv('REPO_TO_DOWNLOAD')
REPO_PATH='/tmp/{}'.format(REPO_URL)

secretsmanager = boto3.client('secretsmanager')

def get_secret(secret_id):
    return secretsmanager.get_secret_value(SecretId=secret_id)['SecretString']

def retrieve_and_save_ssh_key():
    key = get_secret(os.getenv('SSH_KEY_SECRET_ID'))

    # write private key to file
    with open(ID_RSA_PATH, 'w') as file:
        file.write(key)
        # CAUTION!!!
        # this newline is absolutely needed
        # without the newline, the private key will not be in the correct format
        file.write('\n')
    os.chmod(ID_RSA_PATH, 0o400)

def handler(event, context):
    retrieve_and_save_ssh_key()

    os.system('git clone {} {}'.format(REPO_URL, REPO_PATH))
    os.system('tree {}'.format(REPO_PATH))
