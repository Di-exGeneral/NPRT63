import boto3
import os
from dotenv import load_dotenv

load_dotenv()

def get_sns_client():
    return boto3.client(
        "sns",
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
        region_name=os.getenv("AWS_REGION")
    )

def send_sms(phone_number: str, message: str):
    client = get_sns_client()
    client.publish(
        PhoneNumber=phone_number,
        Message=message,
        MessageAttributes={
            "AWS.SNS.SMS.SMSType": {
                "DataType": "String",
                "StringValue": "Transactional"
            }
        }
    )