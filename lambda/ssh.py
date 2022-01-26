import os
import boto3
import paramiko

KEY_PATH='/tmp/key.pem'
s3_client = boto3.client('s3')

def handler(event, context):
    # delete everything in /tmp
    # if the lambda is still running when the next execution happens, the function will not be able to reuse the private key because of the permissions
    os.system('rm -rf /tmp/*')

    s3_client.download_file(os.getenv('S3_BUCKET'), os.getenv('PEM_KEY_PATH'), KEY_PATH)

    host = os.getenv('REMOTE_HOST')
    key = paramiko.RSAKey.from_private_key_file(KEY_PATH)
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print('sshing into remote host {}'.format(host))
    client.connect(hostname=host, username=os.getenv('REMOTE_USER'), pkey=key)

    # run some commands on the remote host    
    for command in ['whoami', 'curl http://checkip.amazonaws.com', 'echo $SSH_CLIENT']:
        print('running command: {}'.format(command))
        stdin, out, err = client.exec_command(command)
        print('stderr', err.read())
        print('stdout', out.read())
