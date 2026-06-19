import os
import json
import logging
import urllib.request
from datetime import datetime
import boto3
from decimal import Decimal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS DynamoDB client
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'ClevelandSportsAnalytics')
table = dynamodb.Table(TABLE_NAME)

# Dedicated ESPN NFL news endpoint filtered for the Cleveland Browns (Team ID: 5)
BROWNS_NEWS_ENDPOINT = "https://site.api.espn.com/apis/site/v2/sports/football/nfl/news?team=5"


def convert_floats(obj):
    """
    Recursively convert Python floats to Decimal for DynamoDB compatibility.
    """
    if isinstance(obj, float):
        return Decimal(str(obj))
    elif isinstance(obj, dict):
        return {k: convert_floats(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_floats(v) for v in obj]
    return obj


def fetch_espn_data(url: str) -> dict:
    """
    Executes an HTTPS fetch to retrieve live data from ESPN's public endpoints.
    """
    try:
        req = urllib.request.Request(
            url,
            headers={
                'User-Agent': 'ClevelandSportsAnalyticsHub/1.0',
                'Accept': 'application/json'
            }
        )
        with urllib.request.urlopen(req, timeout=10) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        logger.error(f"Failed to fetch data from ESPN endpoint {url}: {str(e)}")
        return {}


def extract_browns_news(espn_payload: dict) -> list:
    """
    Parses the articles array from the ESPN news payload into a scannable list structure.
    """
    parsed_articles = []
    try:
        articles = espn_payload.get('articles', [])
        
        for article in articles:
            # Safely navigate nested link structure
            links = article.get('links', {})
            web_link = links.get('web', {}) if isinstance(links, dict) else {}
            web_url = web_link.get('href', 'N/A') if isinstance(web_link, dict) else 'N/A'
            
            parsed_articles.append({
                "headline": article.get('headline', 'No Title'),
                "description": article.get('description', 'No description available.'),
                "published": article.get('published', 'Unknown Time'),
                "link": web_url
            })
            
    except Exception as e:
        logger.warning(f"Error parsing news articles from ESPN payload: {str(e)}")
        
    return parsed_articles


def lambda_handler(event, context):
    """
    Execution handler triggered to hydrate DynamoDB state with latest Browns news.
    """
    logger.info("Executing Cleveland Browns News Ingestion Pipeline.")
    
    # Fetch live data
    raw_payload = fetch_espn_data(BROWNS_NEWS_ENDPOINT)
    if not raw_payload:
        logger.error("Empty or invalid news payload parsed from ESPN. Aborting update.")
        return {
            'statusCode': 500,
            'body': json.dumps("ETL failed. Empty payload received from source.")
        }

    # Extract structured news feed
    latest_news = extract_browns_news(raw_payload)
    
    # Define primary keys and payload body
    db_item = {
        'PK': "TEAM#BROWNS",
        'SK': "METRIC#NEWS",  # Explicit sort key if utilizing a composite key pattern
        'UpdatedTimestamp': datetime.utcnow().isoformat(),
        'League': "NFL",
        'LatestNews': latest_news,
        'ArticleCount': len(latest_news)
    }

    try:
        # Prevent float mapping data type exceptions in DynamoDB
        safe_item = convert_floats(db_item)
        table.put_item(Item=safe_item)
        logger.info("Successfully updated live news feed in DynamoDB for BROWNS.")
        
        return {
            'statusCode': 200,
            'body': json.dumps(f"ETL completed successfully. Ingested {len(latest_news)} Browns headlines.")
        }
        
    except Exception as dbe:
        logger.error(f"DynamoDB transaction failed for BROWNS news write: {str(dbe)}")
        return {
            'statusCode': 500,
            'body': json.dumps("Internal database write failure.")
        }