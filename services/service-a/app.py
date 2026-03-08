from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/service-a/health")
def health():
    return jsonify(status="ok", service="service-a")

@app.route("/service-a")
def index():
    return jsonify(message="Hello from Service A")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)