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

1. API Endpoint:
2. API_KEY: 
3. Usage in the Project: The weather data fetched from the OpenWeather API is processed every hour, stored in DynamoDB and S3, ultimately used to calculate average temperatures and forecast weather patterns.
   
## The Scripts
1. [weather_fetch.py](Project_queries/weather_fetch.py)
    - Fetches hourly weather data from the OpenWeather API using an API key and stores it in DynamoDB.
2. [dynamodb_stream.py](Project_queries/dynamodb_stream.py)
     - Processes new weather data from DynamoDB Streams and archives it into an S3 bucket for analysis.
3. [Snowflake_query.sql](Project_queries/Snowflake_query.sql)
     - Creates a Snowflake stage for seamless integration with the S3 bucket. Ingests new data into Snowflake tables using Snowpipe and performs basic transformations.Calculates the average hourly temperature and weather prediction for the 15 target cities.
  
## Output Showcase 
### Dynamo DB table
 ![Dynamo_db_table](images/DynamoDB_image.png)
   - notes: this image signifies the Dynamo DB table storing the weather data. Major fields include city name, timestamp, weather and temperature.

### S3 Bucket
 ![S3 bucket](images/s3_bucket.png)
   - notes: S3 bucket containing archived weather data files. Each file corresponds to an hourly update for target locations.

### Weather Table
 ![Snowflake table](/images/snowflake_image.png)
   - notes: Results of SQL queries in Snowflake showing the weather forcast date, predicted temperature and predicted weather for 15 cities, calculated from real-time weather data.
     
