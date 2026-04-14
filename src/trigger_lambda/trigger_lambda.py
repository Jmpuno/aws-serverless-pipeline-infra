import boto3
import json
import os
import logging
from urllib.parse import unquote_plus

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
sqs = boto3.client('sqs')

BUCKET_NAME = os.environ["BUCKET_NAME"]
SQS_QUEUE_URL = os.environ["SQS_QUEUE_URL"]

def lambda_handler(event, context):

    logger.info(f"Triggered! Bucket: {BUCKET_NAME}, Queue: {SQS_QUEUE_URL}")


    try:
        for record in event['Records']:
            bucket_name = record['s3']['bucket']['name']
            if bucket_name != BUCKET_NAME:
                logger.warning(f"Skipping unknown bucket: {bucket_name}")
                continue

            object_key = unquote_plus(record['s3']['object']['key'])
            file_details = get_file_details(bucket_name, object_key)

            sqs_message = {
                'file_name': file_details['file_name'],
                'file_size': file_details['size'],
                's3_bucket': bucket_name,
                's3_key':object_key,
                'upload_timestamp': file_details['last_modified'],
                'uploader_email': file_details['uploader_email'],
                'event_time': record['eventTime']
            }

            response = sqs.send_message(
                QueueUrl=SQS_QUEUE_URL,
                MessageBody=json.dumps(sqs_message)
            )

            logger.info(f"✅ Processed: {file_details['file_name']} → MsgId: {response['MessageId']}")

        return {'statusCode': 200, 'body': 'All good!'}
    
    except Exception as e:
        logger.error(f"Failed: {str(e)}")
        raise e

def get_file_details(bucket_name, object_key):
    try:
        response = s3.head_object(Bucket=bucket_name, Key=object_key)
        file_name = object_key.split('/')[-1]
        uploader_email = response.get('Metadata', {}).get('uploader-email', 'unknown')
        
        return {
            'file_name': file_name,
            'size': response['ContentLength'],
            'last_modified': response['LastModified'].isoformat(),
            'uploader_email': uploader_email
        }
    except Exception as e:
        logger.error(f"Metadata error: {e}")
        return {
            'file_name': object_key.split('/')[-1],
            'size': 0,
            'last_modified': 'unknown',
            'uploader_email': 'unknown'
        }