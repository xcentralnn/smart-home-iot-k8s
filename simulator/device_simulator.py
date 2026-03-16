import time
import random
import json
import paho.mqtt.client as mqtt

BROKER="localhost"

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

client.connect(BROKER,1883)

while True:

    payload={
        "temperature":random.uniform(20,35),
        "humidity":random.uniform(40,70),
        "device":"room1",
        "timestamp":time.time()
    }

    client.publish(
        "smarthome/room1",
        json.dumps(payload)
    )

    print(payload)

    time.sleep(3)