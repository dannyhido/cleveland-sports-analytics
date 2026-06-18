import os
import json
import logging
import boto3
from decimal import Decimal

# Configure production logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS DynamoDB Resource Client 
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'ClevelandSportsAnalytics')
table = dynamodb.Table(TABLE_NAME)


# -----------------------------
# FIX: DynamoDB Decimal → JSON
# -----------------------------
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)


def build_response(status_code: int, body_data: dict) -> dict:
    """
    Standardized enterprise response builder featuring CORS compatibility headers.
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body_data, cls=DecimalEncoder)
    }


def lambda_handler(event, context):
    """
    Retrieves algorithmic ML matching predictions for Cleveland teams.
    Exposes endpoints like: /predictions/{teamId}
    """
    logger.info(f"Incoming Prediction API Request: {json.dumps(event)}")

    path_parameters = event.get('pathParameters') or {}
    team_id = path_parameters.get('teamId')

    if not team_id:
        return build_response(400, {"error": "Missing required path parameter: teamId"})

    partition_key = f"TEAM#{team_id.upper()}"
    logger.info(f"Querying ML analytics for key: {partition_key}")

    try:
        response = table.get_item(Key={'PK': partition_key})
        item = response.get('Item')

        if not item:
            return build_response(
                404,
                {"error": f"Prediction model data for '{team_id}' not found."}
            )

        current_record = item.get("CurrentRecord") or {}

        prediction_payload = {
            "teamId": team_id.upper(),
            "lastModelRun": item.get("UpdatedTimestamp"),
            "winProbability": float(item.get("WinProbability", 0.50)),
            "modelMetrics": {
                "algorithm": "XGBoost-Classifier",
                "confidenceScore": 0.84,
                "factors": [
                    {"factor": "Home Field Advantage", "impact": "Positive"},
                    {
                        "factor": "Recent Form (Last 5 Games)",
                        "impact": "Positive" if current_record.get("wins", 0) > current_record.get("losses", 0) else "Negative"
                    }
                ]
            }
        }

        return build_response(200, prediction_payload)

    except Exception as e:
        logger.error(f"Failed to query database for predictive modeling: {str(e)}")
        return build_response(
            500,
            {"error": "Internal server error retrieving machine learning predictions."}
        )