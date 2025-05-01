import os
import time
import boto3
from flask import Flask, request, jsonify
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

ssm = boto3.client('ssm', region_name=os.getenv('AWS_REGION'))
sqs = boto3.client('sqs', region_name=os.getenv('AWS_REGION'))

TOKEN_PARAM_NAME = os.getenv('TOKEN_PARAM_NAME')
SQS_QUEUE_URL = os.getenv('SQS_QUEUE_URL')

def get_token_from_ssm():
    response = ssm.get_parameter(Name=TOKEN_PARAM_NAME, WithDecryption=True)
    return response['Parameter']['Value']

def is_valid_timestream(timestream):
    try:
        timestamp = int(timestream)
        now = int(time.time())
        return abs(now - timestamp) <= 86400  # Allow 24-hour window
    except:
        return False

@app.route('/send-email', methods=['POST'])
def send_email():
    req_data = request.get_json()

    if not req_data or 'token' not in req_data or 'data' not in req_data:
        return jsonify({"error": "Missing token or data"}), 400

    token = req_data['token']
    data = req_data['data']
    print(data)

    # Validate token
    try:
        expected_token = get_token_from_ssm()
    except Exception as e:
        return jsonify({"error": f"Token fetch error: {str(e)}"}), 500

    if token != expected_token:
        return jsonify({"error": "Invalid token"}), 403

    # Validate timestream
    timestream = data.get("email_timestream")
    if not timestream or not is_valid_timestream(timestream):
        return jsonify({"error": "Invalid or missing email_timestream"}), 400

    # Publish to SQS
    try:
        sqs.send_message(QueueUrl=SQS_QUEUE_URL, MessageBody=str(data))
    except Exception as e:
        return jsonify({"error": f"SQS send failed: {str(e)}"}), 500

    return jsonify({"status": "Message sent to SQS"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
