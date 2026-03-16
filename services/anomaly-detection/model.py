from sklearn.ensemble import IsolationForest
import numpy as np

model = IsolationForest(contamination=0.02)

# train model with normal data
def train():

    data = np.random.normal(
        loc=[25,60],
        scale=[3,10],
        size=(200,2)
    )

    model.fit(data)

def detect(sample):

    result = model.predict([sample])

    return result