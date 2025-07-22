from flask import Flask
from datetime import datetime

app = Flask(__name__)

@app.route("/")
def home():
    return f"<h1>Hello from CI/CD 🚀</h1><p>Deployed at: {datetime.utcnow()} UTC</p>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
