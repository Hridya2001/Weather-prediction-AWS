import boto3
import requests
import logging
from datetime import datetime
import json

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
table = dynamodb.Table('weatherdb_table')  # Replace with your table name

# OpenWeather API Key
API_KEY = ''

def fetch_weather(city):
    """Fetch the latest weather data for a given city."""
    try:
        url = f'https://api.openweathermap.org/data/2.5/weather?q={city},IN&appid={API_KEY}&units=metric'
        response = requests.get(url)

        if response.status_code == 200:
            weather_data = response.json()
            return {
                "city": weather_data.get('name', 'Unknown City'),
                "temperature": weather_data['main'].get('temp', 'N/A'),
                "weather": weather_data['weather'][0].get('description', 'N/A'),
                "timestamp": datetime.utcnow().isoformat()  # ISO 8601 timestamp
            }
        else:
            logger.error(f"Failed to fetch weather data for {city}: HTTP {response.status_code}")
            return None
    except Exception as e:
        logger.error(f"Error fetching weather data for {city}: {e}")
        return None

def update_weather_data_in_dynamodb(weather_data):
    """Update the weather data in DynamoDB."""
    try:
        # Extract date from timestamp for the sort key
        date = weather_data["timestamp"].split("T")[0]
        
        # Update DynamoDB item
        response = table.update_item(
            Key={"city": weather_data["city"], "date": date},
            UpdateExpression="SET temperature = :t, weather = :w, #ts = :ts",
            ExpressionAttributeValues={
                ":t": str(weather_data["temperature"]),
                ":w": weather_data["weather"],
                ":ts": weather_data["timestamp"]
            },
            ExpressionAttributeNames={
                "#ts": "timestamp"  # Reserved keyword mapping
            },
            ReturnValues="UPDATED_NEW"
        )
        logger.info(f"Updated DynamoDB record for {weather_data['city']} on {date}: {response}")
    except Exception as e:
        logger.error(f"Failed to update DynamoDB record for {weather_data['city']} on {date}: {e}")

def lambda_handler(event, context):
    """AWS Lambda handler function."""
    cities = [
        'Mumbai', 'Delhi', 'Kolkata', 'Bangalore', 'Chennai', 'Hyderabad',
        'Coimbatore', 'Goa', 'Surat', 'Jaipur', 'Lucknow', 'Bhopal',
        'Nagaland', 'Jodhpur', 'Shimla'
    ]

    for city in cities:
        weather_data = fetch_weather(city)
        if weather_data:
            update_weather_data_in_dynamodb(weather_data)

    return {
        'statusCode': 200,
        'body': json.dumps('Weather data updated successfully.')
    }
