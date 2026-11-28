"""Orders API: create and list orders over HTTP (demo app for skill evals)."""
import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

ORDERS = []


def health():
    return 200, {"status": "ok"}


def list_orders():
    return 200, ORDERS


def create_order(body):
    order = {"id": len(ORDERS) + 1, "item": body.get("item")}
    ORDERS.append(order)
    return 201, order


ROUTES = {
    ("GET", "/health"): health,
    ("GET", "/orders"): list_orders,
    ("POST", "/orders"): create_order,
}


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, payload):
        data = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        route = ROUTES.get(("GET", self.path))
        self._send(*(route() if route else (404, {"error": "not found"})))

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length) or b"{}")
        route = ROUTES.get(("POST", self.path))
        self._send(*(route(body) if route else (404, {"error": "not found"})))


if __name__ == "__main__":
    port = int(sys.argv[sys.argv.index("--port") + 1]) if "--port" in sys.argv else 8000
    HTTPServer(("127.0.0.1", port), Handler).serve_forever()
