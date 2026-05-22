import boto3
import os
import json

sqs = boto3.client('sqs')

TL_DLQ_URL = os.environ["TL_DLQ_URL"]
LW_DLQ_URL = os.environ["LW_DLQ_URL"]
MAIN_QUEUE_URL = os.environ["MAIN_QUEUE_URL"]
MAX_RETRIES = int(os.environ.get("MAX_RETRIES", "3"))

DLQ_URLS = [
    TL_DLQ_URL,
    LW_DLQ_URL
]

def lambda_handler(event, context):

    while True:

        found_messages = False

        for dlq_url in DLQ_URLS:

            response = sqs.receive_message(
                QueueUrl=dlq_url,
                MaxNumberOfMessages=10,
                MessageAttributeNames=['All']
            )

            messages = response.get('Messages', [])

            if not messages:
                continue

            found_messages = True

            for message in messages:

                retry_count = 0

                if (
                    'MessageAttributes' in message and
                    'RetryCount' in message['MessageAttributes']
                ):
                    retry_count = int(
                        message['MessageAttributes']
                        ['RetryCount']
                        ['StringValue']
                    )

                if retry_count >= MAX_RETRIES:
                    print(
                        f"Max retries reached for "
                        f"{message['MessageId']}"
                    )
                    continue

                new_retry_count = retry_count + 1

                sqs.send_message(
                    QueueUrl=MAIN_QUEUE_URL,
                    MessageBody=message['Body'],
                    MessageAttributes={
                        'RetryCount': {
                            'StringValue': str(new_retry_count),
                            'DataType': 'Number'
                        }
                    }
                )

                sqs.delete_message(
                    QueueUrl=dlq_url,
                    ReceiptHandle=message['ReceiptHandle']
                )

                print(
                    f"Requeued {message['MessageId']} "
                    f"with retry count {new_retry_count}"
                )

        if not found_messages:
            break