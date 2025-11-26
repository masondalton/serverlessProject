import json
import os
import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])

def get_benders(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps([
            {"name": "Aang", "nation": "Air", "elements": ["Air"]},
            {"name": "Katara", "nation": "Water", "elements": ["Water"]}
        ])
    }