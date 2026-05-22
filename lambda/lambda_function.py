import json
import boto3
import os

def lambda_handler(event, context):
    """Process messages from SQS"""
    for record in event['Records']:
        try:
            body = json.loads(record['body'])
            print(f"Processing message: {body}")
            
            # TODO: Add your business logic here (e.g., process transfer, send webhook)
            print(f"Successfully processed: {body.get('transfer_id', 'unknown')}")
            
        except Exception as e:
            print(f"Error processing message: {str(e)}")
            raise e  # This will send message to DLQ after retries
    
    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }