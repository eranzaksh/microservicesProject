import boto3
import time
import json
import uuid
import os
from dotenv import load_dotenv

load_dotenv()
AWS_REGION = 'eu-north-1'
sqs = boto3.client('sqs', region_name=AWS_REGION)
s3 = boto3.client('s3', region_name=AWS_REGION)

SQS_QUEUE_URL = os.getenv('SQS_QUEUE_URL')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')


def process_messages():
    while True:
        response = sqs.receive_message(
            QueueUrl=SQS_QUEUE_URL,
            MaxNumberOfMessages=10,
            WaitTimeSeconds=10  # long polling
        )

        messages = response.get('Messages', [])
        for msg in messages:
            body = msg['Body']
            filename = f"inbox/{uuid.uuid4()}.json"

            s3.put_object(
                Bucket=S3_BUCKET_NAME,
                Key=filename,
                Body=body,
                ContentType='application/json'
            )

            sqs.delete_message(
                QueueUrl=SQS_QUEUE_URL,
                ReceiptHandle=msg['ReceiptHandle']
            )
            print(f"Processed and uploaded: {filename}")

        time.sleep(5)  # Pause before next polling

if __name__ == "__main__":
    process_messages()
