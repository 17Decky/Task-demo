import socket
from flask import Flask, jsonify
from functools import wraps

app = Flask(__name__)

# --- Custom decorator to return JSON ---
def json_response(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return jsonify(result)
    return wrapper


# --- Endpoint 1: Hello World ---
@app.route('/')
def hello():
    return 'Hello, World!'


# --- Endpoint 2: Hostname ---
@app.route('/hostname')
@json_response
def get_hostname():
    hostname = socket.gethostname()
    return {"hostname": hostname}


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

