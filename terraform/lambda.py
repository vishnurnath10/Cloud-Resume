import boto3
import json

def lambda_handler(event, context):
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("Dynamodbtable")

    response = table.get_item(Key={"Id": "home"})
    current_count = int(response["Item"]["count"])

    new_count = current_count + 1

    table.put_item(Item={"Id": "home", "count": new_count})
    
    print("Item:", response)

    return {
        "statusCode": 200,
        "body": json.dumps({"count": new_count})
    }
   