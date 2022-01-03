import os
import boto3

ID_RSA_PATH='/tmp/id_rsa'
REPO_URL=os.getenv('REPO_TO_DOWNLOAD')
REPO_PATH='/tmp/{}'.format(REPO_URL.split('/')[-1].split('.')[0])

secretsmanager = boto3.client('secretsmanager')

def show_ssh_github():
    print('showing what errors when sshing to github')
    os.system('ssh -vT git@github.com')

def create_known_hosts_file():
    with open('/tmp/known_hosts', 'w') as file:
        # run "ssh-keyscan -t rsa github.com" to generate this
        file.write('github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==')
    os.chmod('/tmp/known_hosts', 0o644)

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

    print('creating known hosts file')
    create_known_hosts_file()

    print('printing tmp dir')
    os.system('ls /tmp'.format())

    retrieve_and_save_ssh_key()

    print('cloning repo')
    os.system('git clone {} {}'.format(REPO_URL, REPO_PATH))

    print('printing repo dir')
    os.system('ls {}'.format(REPO_PATH))