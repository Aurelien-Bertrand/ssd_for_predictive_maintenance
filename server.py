from flask import Flask, request, jsonify
import faults_classification.MaintainNet as MaintainNet
import math

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    signal = data.get('array', [])
    model = MaintainNet.MaintainNet('MrMaintenance', 2)
    classification = model.predict(signal)

    return jsonify(result=classification)

if __name__ == '__main__':
    app.run(debug=True)
