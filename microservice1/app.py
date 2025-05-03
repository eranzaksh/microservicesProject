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

# Getting token from ssm using aws credentials
def get_token_from_ssm():
    response = ssm.get_parameter(Name=TOKEN_PARAM_NAME, WithDecryption=True)
    return response['Parameter']['Value']

# Checks if the input is a valid Unix timestamp (in seconds) return True or False.
def is_valid_timestream(ts) -> bool:
    if ts is None:
        return False
    try:
        # Convert to int if it's a string
        ts_int = int(ts)
        # Check for a reasonable range (years 1970–2100)
        if ts_int < 0 or ts_int > 4102444800:  # 4102444800 = 2100-01-01 00:00:00 UTC which is maximum
            return False
        # Try to convert to a datetime, if error will return false.
        time.gmtime(ts_int)
        return True
    except (ValueError, OverflowError, TypeError):
        return False

@app.route('/send-email', methods=['POST'])
def send_email():
    req_data = request.get_json()
    # Check if there is data at all and a token
    if not req_data or 'token' not in req_data or 'data' not in req_data:
        return jsonify({"error": "Missing token or data"}), 400

    token = req_data['token']
    data = req_data['data']

    # Validate token
    try:
        expected_token = get_token_from_ssm()
    except Exception as e:
        return jsonify({"error": f"Token fetch error: {str(e)}"}), 500
    # If token in the mail != from the expected token return forbidden 403
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

@app.route("/", methods=["GET"])
def health_root():
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
