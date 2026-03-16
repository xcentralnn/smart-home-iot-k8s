import time
import random
import json
import paho.mqtt.client as mqtt

BROKER = "localhost"
PORT = 31883
TOPIC = "smarthome/room2"

def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print("Connected to MQTT broker")
    else:
        print("Failed to connect:", rc)

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

client.on_connect = on_connect

client.connect(BROKER, PORT)

client.loop_start()

while True:

    payload = {
        "temperature": random.uniform(20, 35),
        "humidity": random.uniform(40, 70),
        "device": "room2",
        "timestamp": time.time()
    }

    client.publish(TOPIC, json.dumps(payload))

    print("Published:", payload)

    time.sleep(3)