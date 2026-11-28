#!/usr/bin/env bash
# Scaffold for this eval case: a throwaway copy of the template (see
# scripts/tests/eval-scaffold.sh) with the orders app, an [ACCEPTED] spec committed,
# and the feature's code left uncommitted, ready to integrate.
set -eu
root="$(cd "$(dirname "$0")/../../../../.." && pwd)"
"$root/scripts/tests/eval-scaffold.sh" --app
mkdir -p specs/features/order-count
cat >specs/features/order-count/spec.md <<'MD'
# Feature: Order Count [ACCEPTED]

> `GET /orders/count` returns how many orders exist.

## Impact

**Today:** clients fetch `GET /orders` and count the list.
**After:** `GET /orders/count` → `200 {"count": <n>}`.
**Files touched:** `src/server.py`.

## Acceptance Criteria

- [ ] With no orders, `GET /orders/count` returns `200 {"count": 0}`.
- [ ] After one `POST /orders`, it returns `200 {"count": 1}`.

## Finish Line

- **Outcome:** a client gets the order count in one request.
- **Run:** `python3 src/server.py --port <port>`
- **Environment:** `local`
- **Check:**
  1. `GET /orders/count` → `200 {"count": 0}`.
  2. `POST /orders {"item": "book"}`, then `GET /orders/count` → `200 {"count": 1}`.

## Open Questions

None.

## Related

- Source files: `src/server.py`
- Tests: —
MD
git add specs && git commit -qm "docs(spec): order count [ACCEPTED]"
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/server.py")
s = p.read_text()
s = s.replace('def create_order(body):', 'def count_orders():\n    return 200, {"count": len(ORDERS)}\n\n\ndef create_order(body):')
s = s.replace('    ("GET", "/orders"): list_orders,\n', '    ("GET", "/orders"): list_orders,\n    ("GET", "/orders/count"): count_orders,\n')
p.write_text(s)
PY
