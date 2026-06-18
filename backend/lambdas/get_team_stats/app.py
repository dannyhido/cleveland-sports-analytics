import os
import json
import logging
import boto3
from boto3.dynamodb.conditions import Key

# Configure production logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS DynamoDB Resource Client 
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'ClevelandSportsAnalytics')
table = dynamodb.Table(TABLE_NAME)

def build_response(status_code: int, body_data: dict) -> dict:
    """
    Helper function to enforce strict, standardized enterprise API formats
    with necessary CORS support for cross-origin Angular clients.
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*", # Adjust to your secure domain in prod
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body_data)
    }

def lambda_handler(event, context):
    """
    Resolves client data requests by querying Single-Table partitions.
    Exposes endpoints like: /teams/{teamId}
    """
    logger.info(f"Incoming API Gateway request received: {json.dumps(event)}")
    
    # Extract path parameters safely out of the HTTP API Event payload
    path_parameters = event.get('pathParameters', {}) or {}
    team_id = path_parameters.get('teamId')
    
    if not team_id:
        return build_response(400, {"error": "Missing required path parameter: teamId"})
    
    # Format partition key to match our database ETL storage convention
    partition_key = f"TEAM#{team_id.upper()}"
    logger.info(f"Querying database partition for partition key: {partition_key}")
    
    try:
        response = table.get_item(Key={'PK': partition_key})
        item = response.get('Item')
        
        if not item:
            logger.warning(f"No sports analytics records found matching partition key: {partition_key}")
            return build_response(404, {"error": f"Analytics records for team '{team_id}' not found."})
            
        return build_response(200, item)
        
    except Exception as e:
        logger.error(f"Failed to fetch data from DynamoDB resource partition: {str(e)}")
        return build_response(500, {"error": "Internal Server Error compiling regional sports intelligence datasets."})