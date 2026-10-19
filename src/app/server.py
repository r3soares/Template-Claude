"""Minimal HTTP API (stdlib only): GET /health and GET /discount?price=&percent=."""

import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

from app.pricing import apply_discount


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        if url.path == "/health":
            return self._send(200, {"status": "ok"})
        if url.path == "/discount":
            query = parse_qs(url.query)
            try:
                price = float(query["price"][0])
                percent = float(query["percent"][0])
                return self._send(200, {"total": apply_discount(price, percent)})
            except (KeyError, ValueError) as exc:
                return self._send(400, {"error": str(exc)})
        return self._send(404, {"error": "not found"})

    def _send(self, status, body):
        data = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *args):  # keep test output quiet
        pass


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8080"))
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()
