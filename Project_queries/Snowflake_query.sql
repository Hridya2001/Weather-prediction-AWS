-- creating a database
CREATE or REPLACE DATABASE WEATHER_DB;
USE DATABASE WEATHER_DB;

-- Creating scema
CREATE or REPLACE SCHEMA IF NOT EXISTS public;
USE SCHEMA public;

-- Creating a warehouse
CREATE or REPLACE WAREHOUSE my_warehouse
WITH WAREHOUSE_SIZE = 'SMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

--  Create the target table
CREATE OR REPLACE TABLE my_table (
    json_data VARIANT
);
-- Step 2: Create and enable storage integration
CREATE OR REPLACE STORAGE INTEGRATION my_s3_integration
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::886436955513:role/weather_role'
STORAGE_ALLOWED_LOCATIONS = ('s3://weatherbucket2025');
ALTER STORAGE INTEGRATION my_s3_integration SET ENABLED = TRUE;

--  Describe the storage integration
DESCRIBE INTEGRATION my_s3_integration;

-- Create the stage
CREATE OR REPLACE STAGE my_stage
STORAGE_INTEGRATION = my_s3_integration
URL = 's3://weatherbucket2025/weather_data/';

--  Describe and list stage
DESCRIBE STAGE my_stage;
LIST @my_stage

-- Create the file format
CREATE OR REPLACE FILE FORMAT my_file_format
TYPE = 'JSON';

-- Create the notification integration
CREATE OR REPLACE NOTIFICATION INTEGRATION my_notification_integration
ENABLED = TRUE
TYPE = QUEUE
NOTIFICATION_PROVIDER = AWS_SNS
AWS_SNS_TOPIC_ARN = 'arn:aws:sns:ap-south-1:886436955513:weather_topic'
AWS_SNS_ROLE_ARN = 'arn:aws:iam::886436955513:role/weather_role'
DIRECTION = OUTBOUND;

-- Verify the notification integration
DESCRIBE INTEGRATION my_notification_integration;

-- grant permission for the role
GRANT USAGE ON INTEGRATION my_notification_integration TO ROLE ACCOUNTADMIN;
GRANT CREATE PIPE ON SCHEMA PUBLIC TO ROLE ACCOUNTADMIN;
GRANT USAGE ON DATABASE WEATHER_DB TO ROLE ACCOUNTADMIN;
GRANT USAGE ON SCHEMA WEATHER_DB.PUBLIC TO ROLE ACCOUNTADMIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA WEATHER_DB.PUBLIC TO ROLE ACCOUNTADMIN;
GRANT SELECT ON ALL TABLES IN SCHEMA WEATHER_DB.PUBLIC TO ROLE ACCOUNTADMIN;
GRANT SELECT ON FUTURE TABLES IN SCHEMA WEATHER_DB.PUBLIC TO ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE MY_WAREHOUSE TO ROLE ACCOUNTADMIN;
GRANT OPERATE ON WAREHOUSE MY_WAREHOUSE TO ROLE ACCOUNTADMIN;

-- Creating the pipe
CREATE OR REPLACE PIPE my_pipe
AUTO_INGEST = TRUE
AS
COPY INTO my_table
FROM @my_stage
FILE_FORMAT = (FORMAT_NAME = my_file_format);

-- show and varify the pipe
SHOW PIPES;


COPY INTO my_table
FROM @my_stage
FILE_FORMAT = (FORMAT_NAME = my_file_format);
SELECT * FROM my_table limit 10;

-- creating a table for storing cleaned and ranked data
CREATE OR REPLACE TABLE WEATHER_CLEANED_RANKED AS
WITH cleaned_data AS (
  SELECT
    json_data:city::STRING AS city,
    json_data:date::DATE AS date,
    REGEXP_REPLACE(json_data:temperature::STRING, '°C', '')::FLOAT AS temperature,
    json_data:weather::STRING AS weather,
    json_data:event_timestamp::TIMESTAMP AS event_timestamp
  FROM my_table
  WHERE
    json_data:city IS NOT NULL
    AND json_data:date IS NOT NULL
    AND json_data:temperature IS NOT NULL
    AND json_data:weather IS NOT NULL
    AND json_data:city IN ('Mumbai', 'Delhi', 'Kolkata', 'Bengaluru', 'Chennai', 'Hyderabad',
                           'Coimbatore', 'Goa', 'Surat', 'Jaipur', 'Lucknow', 'Bhopal',
                           'Nagaland', 'Jodhpur', 'Shimla') -- Target cities only
),
ranked_data AS (
  SELECT
    city,
    date,
    temperature,
    weather,
    event_timestamp,
    ROW_NUMBER() OVER (
      PARTITION BY city, date
      ORDER BY event_timestamp DESC  -- Changed from 'timestamp' to 'event_timestamp'
    ) AS row_num
  FROM cleaned_data
)
SELECT city, date, temperature, weather, event_timestamp  -- Changed 'timestamp' to 'event_timestamp'
FROM ranked_data
WHERE row_num = 1; 


-- Insert Transformed Data
INSERT INTO WEATHER_CLEANED_RANKED (city, date, temperature, weather, event_timestamp)
SELECT
    json_data:NewItem.city.S::STRING AS city,
    json_data:NewItem.date.S::DATE AS date,
    REPLACE(json_data:NewItem.temperature.S::STRING, '°C', '')::FLOAT AS temperature,
    json_data:NewItem.weather.S::STRING AS weather,
    json_data:NewItem.timestamp.S::TIMESTAMP_NTZ AS event_timestamp
FROM my_table;

SELECT * FROM WEATHER_CLEANED_RANKED;


-- to check and set the time zone for database 
SELECT CURRENT_DATE;
SHOW PARAMETERS LIKE 'TIMEZONE';
ALTER SESSION SET TIMEZONE = 'Asia/Kolkata'; -- Replace with your desired time zone
SHOW PARAMETERS LIKE 'TIMEZONE';
SELECT CURRENT_DATE, CURRENT_TIMESTAMP;

-- calculating average temperature
CREATE OR REPLACE TABLE city_weather_summary AS
SELECT
  city,
  AVG(temperature) AS avg_temperature,
  COUNT(*) AS record_count
FROM WEATHER_CLEANED_RANKED
GROUP BY city;

select * from city_weather_summary;

-- weather forcast
CREATE OR REPLACE TABLE weather_forecast AS
WITH recent_data AS (
  SELECT
    city,
    AVG(temperature) AS avg_temperature
  FROM WEATHER_CLEANED_RANKED
  WHERE city IN ('Mumbai', 'Delhi', 'Kolkata', 'Bengaluru', 'Chennai', 'Hyderabad',
                 'Coimbatore', 'Goa', 'Surat', 'Jaipur', 'Lucknow', 'Bhopal',
                 'Nagaland', 'Jodhpur', 'Shimla')  -- Filter for targeted cities
  GROUP BY city
),
forecast_data AS (
  SELECT
    city,
    CURRENT_DATE + INTERVAL '1 DAY' AS forecast_date,  -- Forecast for tomorrow
    avg_temperature AS predicted_temperature,
    CASE
      WHEN avg_temperature > 30 THEN 'Hot'
      WHEN avg_temperature >= 20 AND avg_temperature <= 30 THEN 'Moderate'
      ELSE 'Cold'
    END AS predicted_weather
  FROM recent_data
)
SELECT
  city,
  forecast_date,
  predicted_temperature,
  predicted_weather
FROM forecast_data;

SELECT * FROM weather_forecast;

---------------------------------------------------------------------------














