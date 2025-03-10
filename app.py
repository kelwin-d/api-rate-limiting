from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/my-api', methods=['GET'])
def my_api():
    return jsonify({"message": "Rate Limiting Test API"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

