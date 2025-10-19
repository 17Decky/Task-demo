import socket
from flask import Flask, jsonify, request, Response
from functools import wraps
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# --- Prometheus metrics ---
REQUEST_COUNTER = Counter(
    'http_requests_total', 'Total HTTP Requests', ['method', 'endpoint', 'http_status']
)

# --- Middleware to count requests ---
@app.before_request
def before_request():
    request._start_path = request.path  # Save path to use in after_request


@app.after_request
def after_request(response):
    REQUEST_COUNTER.labels(
        method=request.method,
        endpoint=request._start_path,
        http_status=response.status_code
    ).inc()
    return response

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

# --- Prometheus metrics endpoint ---
@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

