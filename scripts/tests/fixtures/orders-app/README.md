# orders-api

> A tiny HTTP API to create and list orders (Python 3, standard library only).

## Running Locally

```bash
python3 src/server.py --port 8000
```

Endpoints: `GET /health`, `GET /orders`, `POST /orders` with JSON `{"item": "..."}`.

## Environments

- **Local:** the command above; answers on `http://127.0.0.1:<port>`.
- **Staging:** none.
