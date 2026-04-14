import boto3
import json
import os

BUCKET_NAME = os.environ["BUCKET_NAME"]
s3 = boto3.client('s3')

ACCEPTED_FILE_TYPES = [
    "text/csv",
    "application/json",
    "application/pdf",
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/webp",
    "image/svg+xml",
]

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "http://localhost:5500",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "POST,OPTIONS"
}

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))

        email = body.get("email", "")
        email = email.strip().lower()
        
        filename = body.get("filename", "")
        filename = os.path.basename(filename)
       
        content_type = body.get("contentType", "")

   
        if content_type not in ACCEPTED_FILE_TYPES:
            return {
                "statusCode": 400,
                "headers":CORS_HEADERS,
                "body": json.dumps({"error": "File type is not allowed"})
            }

        
        if not email or not filename:
            return {
                "statusCode": 400,
                "headers":CORS_HEADERS,
                "body": json.dumps({"error": "Missing email or filename"})
            }

   
        key = f"uploads/{email}/{filename}"

        
        presigned_post = s3.generate_presigned_post(
            Bucket=BUCKET_NAME,
            Key=key,
            Fields={
                "Content-Type": content_type,
                "x-amz-meta-email":email
            },
            Conditions=[
                ["eq", "$Content-Type", content_type],
                ["eq", "$x-amz-meta-email", email],
                ["content-length-range", 0, 5 * 1024 * 1024]
            ],
            ExpiresIn=3600
        )

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps(presigned_post)
        }
    except Exception as e:
        return {
            "statusCode":500,
            "headers":CORS_HEADERS,
            "body":json.dumps({
                "error": "Internal server error"
            })
        }