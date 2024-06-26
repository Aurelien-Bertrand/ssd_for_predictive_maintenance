import argparse
from flask import Flask, request, jsonify
from faults_classification.MaintainNet import MaintainNet
import math
from faults_classification.get_model import get_model

parser = argparse.ArgumentParser(description="Run the Flask server with boolean flags.")
parser.add_argument("use_realistic_data", type=lambda x: (str(x).lower() == "true"))
args = parser.parse_args()

app = Flask(__name__)

model = get_model(args.use_realistic_data)

@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()
    signal = data.get("array", [])

    classification = model.predict(signal)

    return jsonify(result=classification)

if __name__ == "__main__":
    app.run(debug=True)
