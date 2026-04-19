import boto3
import json
import os
import csv
import io
import logging
import uuid

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
dynamodb = boto3.client('dynamodb')
sns = boto3.client('sns')
ses = boto3.client('ses')

DYNAMODB_TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
SES_SENDER_EMAIL = os.environ["SES_SENDER_EMAIL"]


def process_file(s3_bucket, s3_key, content_type):
    try:
        response = s3.get_object(Bucket=s3_bucket, Key=s3_key)
        file_content = response['Body'].read()
        
        if content_type == 'text/csv':
            return process_csv(file_content)
        elif content_type == 'application/json':
            return process_json(file_content)
        else:
            # PDF, images — basic metadata lang
            return {
                'status': 'validated',
                'file_type': content_type,
                'size_bytes': len(file_content)
            }
    except Exception as e:
        logger.error(f"Error processing file: {str(e)}")
        raise e

def process_csv(content):
    
    reader = csv.reader(io.StringIO(content.decode('utf-8')))
    rows = list(reader)
    return {
        'status': 'validated',
        'total_rows': len(rows) - 1,  # minus header
        'columns': rows[0] if rows else [],
        'file_type': 'csv'
    }

def process_json(content):
    data = json.loads(content.decode('utf-8'))
    return {
        'status': 'validated',
        'file_type': 'json',
        'total_keys': len(data) if isinstance(data, dict) else len(data)
    }

def save_to_dynamodb(file_data):

    file_id = str(uuid.uuid4())
    file_data['FileID'] = file_id

    try:
        dynamodb.put_item(
            TableName=DYNAMODB_TABLE_NAME,
            Item={
                'FileID': {'S': file_data['FileID']},
                'file_name': {'S': file_data['file_name']},
                'file_size': {'N': str(file_data['file_size'])},
                's3_bucket': {'S': file_data['s3_bucket']},
                's3_key': {'S': file_data['s3_key']},
                'upload_timestamp': {'S': file_data['upload_timestamp']},
                'uploader_email': {'S': file_data['uploader_email']},
                'process_result':   {'S': json.dumps(file_data.get('status', 'unknown'))}
            }
        )
        logger.info(f"Metadata saved to DynamoDB for file: {file_data['file_name']} with ID: {file_data['FileID']}")
    except Exception as e:
        logger.error(f"Error saving to DynamoDB: {str(e)}")
        raise e 
    
def send_email_notification(file_data):
    try:
        subject = f"File Uploaded: {file_data['file_name']}"
        body = f"""
        Hello,

        A new file has been uploaded to S3.

        File Name: {file_data['file_name']}
        File Size: {file_data['file_size']} bytes
        S3 Bucket: {file_data['s3_bucket']}
        S3 Key: {file_data['s3_key']}
        Upload Timestamp: {file_data['upload_timestamp']}

        Best regards,
        Your Lambda Worker
        """
        ses.send_email(
            Source=SES_SENDER_EMAIL,
            Destination={'ToAddresses': [file_data['uploader_email']]},
            Message={
                'Subject': {'Data': subject},
                'Body': {'Text': {'Data': body}}
            }
        )
        logger.info(f"Email notification sent to: {file_data['uploader_email']}")
    except Exception as e:
        logger.error(f"Error sending email: {str(e)}")
        raise e

def send_admin_notification(file_data):
    try:
        message = f"New file uploaded: {file_data['file_name']} in bucket: {file_data['s3_bucket']}"
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=message,
            Subject="New File Uploaded"
        )
        logger.info("Admin notification sent via SNS")
    except Exception as e:
        logger.error(f"Error sending admin notification: {str(e)}")
        raise e


def lambda_handler(event, context):
    logger.info(f"Lambda Worker triggered with event: {json.dumps(event)}")

    try:
        for record in event['Records']:
            message_body = json.loads(record['body'])
            file_name = message_body['file_name']
            file_size = message_body['file_size']
            s3_bucket = message_body['s3_bucket']
            s3_key = message_body['s3_key']
            upload_timestamp = message_body['upload_timestamp']
            uploader_email = message_body['uploader_email']


            logger.info(f"Processing file: {file_name} from bucket: {s3_bucket}")

            # Validate and process file
            process_result = process_file(s3_bucket, s3_key, message_body.get('content_type', 'unknown'))
            combine_data = {**message_body, **process_result}

            # Store metadata in DynamoDB
            save_to_dynamodb(combine_data)

            # Send email notification to uploader
            send_email_notification(combine_data)

            # Send admin notification via SNS
            send_admin_notification(combine_data)
    
    except Exception as e:
        logger.error(f"Error processing message: {str(e)}")
        raise e
