import joblib
import pandas as pd
import os
import time

MODEL_PATH = os.getenv("MODEL_PATH", "/models/model.joblib")

model = None
last_loaded = 0


def load_model():
    global model, last_loaded

    print("Loading model:", MODEL_PATH)

    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(f"Model not found at {MODEL_PATH}")

    model = joblib.load(MODEL_PATH)
    last_loaded = time.time()


def ensure_model_loaded():
    global model, last_loaded

    # first load
    if model is None:
        load_model()

    # hot reload every 5 minutes (optional but recommended)
    elif time.time() - last_loaded > 300:
        print("Reloading model...")
        load_model()


def detect(sample):
    ensure_model_loaded()

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