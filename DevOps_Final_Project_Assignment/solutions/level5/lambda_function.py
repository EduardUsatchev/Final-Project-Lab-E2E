import boto3
import os

def lambda_handler(event, context):
    secret_name = os.environ.get('SECRET_NAME')
    region_name = os.environ.get('AWS_REGION', 'us-east-1')
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = response['SecretString']
    except Exception as e:
        secret = str(e)
    return {
        'statusCode': 200,
        'body': secret
    }
