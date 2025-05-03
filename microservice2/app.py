import boto3
import uuid
import os
from dotenv import load_dotenv
from apscheduler.schedulers.blocking import BlockingScheduler

load_dotenv()

sqs = boto3.client('sqs', region_name=os.getenv('AWS_REGION'))
s3 = boto3.client('s3', region_name=os.getenv('AWS_REGION'))

SQS_QUEUE_URL = os.getenv('SQS_QUEUE_URL')
S3_BUCKET_NAME = os.getenv('S3_BUCKET_NAME')

def process_messages():
    print("Checking for messages...")
    response = sqs.receive_message(
        QueueUrl=SQS_QUEUE_URL,
        MaxNumberOfMessages=2,
        WaitTimeSeconds=5
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

if __name__ == "__main__":
    # Using scheduler to avoid using a while true loop
    scheduler = BlockingScheduler()
    scheduler.add_job(process_messages, 'interval', minutes=5)
    scheduler.start()
