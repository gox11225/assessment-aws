from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/service-b/health")
def health():
    return jsonify(status="ok", service="service-b")

@app.route("/service-b")
def index():
    return jsonify(message="Hello from Service B")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)