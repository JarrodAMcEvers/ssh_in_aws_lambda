import os
import boto3

ID_RSA_PATH='/tmp/id_rsa'
REPO_URL=os.getenv('REPO_TO_DOWNLOAD')
REPO_PATH='/tmp/{}'.format(REPO_URL.split('/')[-1].split('.')[0])

secretsmanager = boto3.client('secretsmanager')

def show_ssh_github():
    print('showing what errors when sshing to github')
    os.system('ssh -vT git@github.com')

def retrieve_and_save_ssh_key():
    key = secretsmanager.get_secret_value(SecretId=os.getenv('SSH_KEY_SECRET_ID'))['SecretString']

    with open(ID_RSA_PATH, 'w') as file:
        file.write(key)
        # without the newline, the private key will not be in the correct format
        file.write('\n')
    os.chmod(ID_RSA_PATH, 0o400)

def handler(event, context):
    if os.getenv('DEBUG_SSH', '').lower() == 'true':
        show_ssh_github()

    # delete everything in /tmp
    # if the lambda is still running when the next execution happens, the function will not be able to reuse the private key because of the permissions
    os.system('rm -rf /tmp/*')

    print('printing tmp dir')
    os.system('ls /tmp'.format())
    print('\n')

    retrieve_and_save_ssh_key()

    print('cloning repo')
    os.system('git clone {} {}'.format(REPO_URL, REPO_PATH))
    print('\n')

    print('printing repo dir')
    os.system('ls {}'.format(REPO_PATH))
    print('\n')
