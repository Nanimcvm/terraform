import boto3
import gzip
import json
import base64
import datetime

s3 = boto3.client("s3")

def lambda_handler(event, context):
    compressed = base64.b64decode(event["awslogs"]["data"])
    decompressed = gzip.decompress(compressed)
    log_data = json.loads(decompressed)

    timestamp = datetime.datetime.utcnow().isoformat()
    key = f"cloudwatch/{timestamp}.json"

    s3.put_object(
        Bucket="my-cw-log-export-bucket-12345",
        Key=key,
        Body=json.dumps(log_data)
    )

    return {"status": "ok"}
