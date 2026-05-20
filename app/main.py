from fastapi import FastAPI
import boto3
import json
import os

app = FastAPI(title="NairaTransfer Pro", version="1.0.0")

sqs = boto3.client('sqs', region_name=os.getenv('AWS_REGION', 'eu-north-1'))
QUEUE_URL = os.getenv('SQS_QUEUE_URL')

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "nairatransfer-pro",
        "environment": "prod"
    }

@app.post("/transfer")
def create_transfer(transfer: dict):
    """Create a transfer and send it to SQS for processing."""
    try:
        response = sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(transfer),
            MessageAttributes={
                'TransferType': {
                    'StringValue': transfer.get('type', 'standard'),
                    'DataType': 'String'
                }
            }
        )
        return {
            "status": "success",
            "message_id": response.get("MessageId"),
            "transfer": transfer
        }
    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }
