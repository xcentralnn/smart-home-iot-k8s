import json
import os
import paho.mqtt.client as mqtt
from influxdb_client import InfluxDBClient, Point, WritePrecision
from model import detect

BROKER = os.getenv("MQTT_HOST", "mqtt")
PORT = int(os.getenv("MQTT_BROKER_PORT", 1883))

INFLUX_URL = os.getenv("INFLUX_URL", "http://influxdb:8086")
INFLUX_TOKEN = os.getenv("INFLUX_TOKEN", "xW3RESD2")
ORG = os.getenv("INFLUX_ORG", "iot")
BUCKET = os.getenv("INFLUX_BUCKET", "sensors")

print("Connecting to InfluxDB:", INFLUX_URL)

client = InfluxDBClient(
    url=INFLUX_URL,
    token=INFLUX_TOKEN,
    org=ORG
)

write_api = client.write_api()

print("Connecting to MQTT:", BROKER, PORT)


def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print("Connected to MQTT broker")
        client.subscribe("smarthome/#")
    else:
        print("MQTT connection failed:", rc)


def on_message(client, userdata, msg):
    try:
        data = json.loads(msg.payload)
        print("Received:", data)

        temp = data["temperature"]
        hum = data["humidity"]

        result = detect([temp, hum])

        score = result["score"]
        anomaly = result["anomaly"]

        print("Anomaly result:", result)

        point = (
            Point("anomaly")
            .tag("device", data["device"])
            .field("score", score)
            .field("anomaly", anomaly)
            .time(int(data["timestamp"] * 1e9), WritePrecision.NS)
        )

        write_api.write(bucket=BUCKET, record=point)

    except Exception as e:
        print("Error processing message:", e)


mqtt_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

mqtt_client.on_connect = on_connect
mqtt_client.on_message = on_message

mqtt_client.connect(BROKER, PORT)

mqtt_client.loop_forever()