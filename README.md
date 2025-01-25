# Real time Weather Data Pipeline

## Introduction
This project showcases a real-time weather data pipeline designed to predict weather patterns for 15 targeted cities. By leveraging the power of AWS cloud services, Snowflake, and SQL-based analysis, the pipeline seamlessly processes, stores, and analyzes hourly weather updates from a reliable weather API. The real-time data integration ensures accurate and timely forecasts, making it a robust solution for understanding and predicting weather trends.

## Architecture
![Architecture](images/weather_image.jpeg)

## Technology Used
1. Programming Language - Python
2. Scripting Language - SQL
3. AWS
   - lambda
   - Event Bridge
   - Dynamo DB
   - S3
   - SQS
4. Snowflake

## Data Source
Used weather data from the [OpenWeather API](https://openweathermap.org/api). The API provides real-time weather updates, including city name, temperature, weather condition and timestamp, for various cities in India.

1. API Endpoint: https://openweathermap.org/api
2. API_KEY: '2d9edf547e934049ae34de80e57d9e70'
3. Usage in the Project: The weather data fetched from the OpenWeather API is processed every hour, stored in DynamoDB and S3, Ultimately used to calculate average temperatures and forecast weather patterns.
   
## The Scripts
1. [weather_fetch.py](weather_fetch.py)
  - Fetches hourly weather data from the OpenWeather API using an API key and stores it in DynamoDB.
