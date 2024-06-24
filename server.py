from flask import Flask, request, jsonify
import MaintainNet as MaintainNet
import math
import torch

app = Flask(__name__)

model = MaintainNet.MaintainNet('MrMaintenance', 4)
model.load_state_dict(torch.load('./models/simplemodel.pth'))
model.eval()

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    signal = data.get('array', [])


    classification = model.predict(signal)

    return jsonify(result=classification)

if __name__ == '__main__':
    app.run(debug=True)
