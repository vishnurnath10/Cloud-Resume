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
         "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
                "Access-Control-Allow-Methods": "GET,OPTIONS",
                "Content-Type": "application/json"
            },
        "body": json.dumps({"count": new_count})
    }
   
