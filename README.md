# Real_time_weatherdata_Pipeline

This project showcases a fully automated data pipeline using the powers of AWS like Eventbridge, Lambda, Dynamo DB, S3 and Snowflake. It entails designing and implementing a real-time weather data pipeline to process and analyse the weather updates. The objective is to enable predictive insights for weather pattern.




Here the Open weather API is used to collect real-time weather data like city name, temperature, weather and timestamp of taregetd location. 
An event bridge is initiated to trigger thelambda function hourly and scheduling the events.
The row data is processed through the lambda function and stored in the Dynamo DB.


Dynamo DB stream tracks the changes in the table. 
Once the data in added, modified or deleted from the table the Dynamo DB stream detect it.
They trigger the next lambda function to archive the modified data into s3 bucket.


Storage integration Securely connects S3 with Snowflake for seamless data transfer.
In the process s3 serves as an external stage for snowflake.
For the automatic and continuous ingestion of data from s3 to snowflake table we created a snowpipe which is triggerd by the SQS queue. 


Fianlly calculate the average temperature and the weather forcast od each cities.

Here’s your original text rearranged with bullet points while keeping your wording intact:

---

# Real-Time Weather Data Pipeline  

This project showcases a fully automated data pipeline using the powers of AWS like **EventBridge**, **Lambda**, **DynamoDB**, **S3**, and **Snowflake**. It entails designing and implementing a real-time weather data pipeline to process and analyze the weather updates. The objective is to enable predictive insights for weather patterns.  

---

## 🛠️ How It Works  

### **Data Collection**  
- The **OpenWeather API** is used to collect real-time weather data, including:  
  - City name  
  - Temperature  
  - Weather  
  - Timestamp of the targeted location  

### **Event Scheduling**  
- **AWS EventBridge** is initiated to:  
  - Trigger the **Lambda function** hourly.  
  - Schedule the events for automation.  

### **Data Processing and Storage**  
- The raw weather data is processed through the **Lambda function**.  
- The processed data is stored in **DynamoDB**.  

### **Real-Time Tracking with DynamoDB Streams**  
- **DynamoDB Streams** track changes in the table.  
- When data is added, modified, or deleted:  
  - The **DynamoDB Stream** detects it.  
  - The **next Lambda function** is triggered to archive the modified data into an **S3 bucket**.  

### **Integration with Snowflake**  
- **Storage Integration** securely connects **S3** with **Snowflake** for seamless data transfer.  
- **Amazon S3** serves as an **external stage** for Snowflake.  
- For automatic and continuous ingestion of data from S3 to Snowflake tables:  
  - A **Snowpipe** is created.  
  - The **Snowpipe** is triggered by an **SQS queue**.  

### **Final Insights**  
- The pipeline calculates:  
  - **Average temperature** for each city.  
  - **Weather forecasts** for the targeted cities.  

