import os
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def index():
    return jsonify(
        service="payment-api",
        status="ok",
        version=os.getenv("APP_VERSION", "dev"),
        commit=os.getenv("GIT_COMMIT", "unknown"),
        branch=os.getenv("BRANCH_NAME", "unknown"),
    )


@app.route("/health")
def health():
    return jsonify(status="healthy")


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "5000"))
    host = os.environ.get("HOST", "127.0.0.1")
    app.run(host=host, port=port)
