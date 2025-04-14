import json
import boto3
import requests


def lambda_handler(event, context):
    print("Event:" + str(event))
    data = json.dumps(event)
    print("Event:" + data)
    print("Execution complete")
    print(f"Version of requests library: {requests.__version__}")
    request = requests.get('https://api.github.com/')
    return {
        'statusCode': request.status_code,
        'body': request.text
    }