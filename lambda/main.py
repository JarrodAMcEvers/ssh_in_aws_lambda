import os

def handler(event, context):
    os.system('ssh -vT git@github.com')
