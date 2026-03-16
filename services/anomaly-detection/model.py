import joblib
import pandas as pd
import os

MODEL_PATH = os.getenv("MODEL_PATH", "model.joblib")

print("Loading model:", MODEL_PATH)

model = joblib.load(MODEL_PATH)

def detect(sample):

    sample = pd.DataFrame(
        [sample],
        columns=["temperature", "humidity"]
    )

    score = model.decision_function(sample)[0]
    label = model.predict(sample)[0]

    return {
        "score": float(score),
        "anomaly": int(label)
    }