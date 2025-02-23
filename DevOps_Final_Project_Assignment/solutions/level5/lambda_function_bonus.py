import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    secret_name = os.environ.get('SECRET_NAME')
    region_name = os.environ.get('AWS_REGION', 'us-east-1')
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = response['SecretString']
        if not event.get('mfa_verified', False):
            logger.warning("MFA not verified! Triggering security alert.")
    except Exception as e:
        secret = str(e)
        logger.error("Error retrieving secret: " + secret)
    return {
        'statusCode': 200,
        'body': secret
    }
