import boto3
import os
import uuid
from dotenv import load_dotenv

load_dotenv()

s3_client = boto3.client(
    "s3",
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    region_name=os.getenv("AWS_REGION")
)

BUCKET_NAME = os.getenv("AWS_BUCKET_NAME")

def upload_photo(file, folder: str = "photos") -> str:
    file_extension = file.filename.split(".")[-1]
    file_key = f"{folder}/{uuid.uuid4()}.{file_extension}"
    s3_client.upload_fileobj(file.file, BUCKET_NAME, file_key)
    url = f"https://{BUCKET_NAME}.s3.{os.getenv('AWS_REGION')}.amazonaws.com/{file_key}"
    return url

def delete_photo(file_key: str):
    s3_client.delete_object(Bucket=BUCKET_NAME, Key=file_key)