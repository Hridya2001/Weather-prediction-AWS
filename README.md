# Real_time_weatherdata_Pipeline

This project showcases a fully automated data pipeline using the powers of AWS like Eventbridge, Lambda, Dynamo DB, S3 and Snowflake. It entails designing and implementing a real-time weather data pipeline to process and analyse the weather updates. The objective is to enable predictive insights for weather pattern.


![daigram](weather1_image.png)

Here the Open weather API is used to collect real-time weather data like city name, temperature, weather and timestamp of taregetd location. 
An event bridge is initiated to trigger thelambda function hourly and scheduling the events.
