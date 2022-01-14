import os
import boto3
import paramiko

KEY_PATH='/tmp/key.pem'
s3_client = boto3.client('s3')

def handler(event, context):
    # delete everything in /tmp
    # if the lambda is still running when the next execution happens, the function will not be able to reuse the private key because of the permissions
    os.system('rm -rf /tmp/*')

    s3_client.download_file(os.getenv('S3_BUCKET'), os.getenv('OBJECT_PATH'), KEY_PATH)

    host = os.getenv('IP_ADDRESS')
    key = paramiko.RSAKey.from_private_key_file(KEY_PATH)
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    print('sshing into remote host')
    client.connect(hostname=host, username="ubuntu", pkey=key)

    # run some commands on the remote host    
    for command in ['whoami', 'curl http://checkip.amazonaws.com']:
        print('running command: {}'.format(command))
        stdin, out, err = client.exec_command(command)
        print('stderr', err.read())
        print('stdout', out.read())
