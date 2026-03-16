import random
import time
from model import detect, train

print("Training model...")

train()

print("Model ready")

while True:

    sample = [
        random.uniform(20,40),
        random.uniform(40,90)
    ]

    result = detect(sample)

    if result[0] == -1:

        print("ANOMALY:", sample)

    else:

        print("Normal:", sample)

    time.sleep(5)