import json
import paho.mqtt.client as mqtt
from influxdb_client import InfluxDBClient, Point, WritePrecision

BROKER="mqtt"

bucket="sensors"
org="iot"
token="my-token"

influx = InfluxDBClient(
    url="http://influxdb:8086",
    token=token,
    org=org
)

write_api = influx.write_api()

def on_connect(client, userdata, flags, rc, properties=None):

    print("Connected to MQTT")

    client.subscribe("smarthome/#")

def on_message(client, userdata, msg):

    data=json.loads(msg.payload)

    print("Received:",data)

    point = Point("environment")\
        .tag("device",data["device"])\
        .field("temperature",data["temperature"])\
        .field("humidity",data["humidity"])\
        .time(int(data["timestamp"] * 1e9), WritePrecision.NS)

    write_api.write(bucket=bucket, record=point)

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

client.on_connect = on_connect
client.on_message = on_message

client.connect(BROKER,1883)

client.loop_forever()