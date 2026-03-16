from influxdb_client import InfluxDBClient
import pandas as pd
from sklearn.ensemble import IsolationForest
import joblib
import os

INFLUX_URL = os.getenv("INFLUX_URL", "http://influxdb:8086")
INFLUX_TOKEN = os.getenv("INFLUX_TOKEN", "xW3RESD2")
ORG = os.getenv("INFLUX_ORG", "iot")
BUCKET = os.getenv("INFLUX_BUCKET", "sensors")

print("Connecting to InfluxDB")

client = InfluxDBClient(
    url=INFLUX_URL,
    token=INFLUX_TOKEN,
    org=ORG
)

query = f'''
from(bucket:"{BUCKET}")
|> range(start:-7d)
|> filter(fn:(r)=>r._measurement=="environment")
|> pivot(rowKey:["_time"], columnKey:["_field"], valueColumn:"_value")
'''

print("Loading historical data")

tables = client.query_api().query_data_frame(query)

if isinstance(tables, list):
    df = pd.concat(tables)
else:
    df = tables

# Keep only the ML features
data = df[["temperature", "humidity"]].dropna()

print("Training IsolationForest")

model = IsolationForest(
    contamination=0.02,
    random_state=42
)

model.fit(data)

joblib.dump(model, "model.joblib")

print("Model saved → model.joblib")