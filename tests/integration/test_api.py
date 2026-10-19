"""Integration tests against the real container started by `with_compose`."""

import json
import os
import unittest
from urllib.error import HTTPError
from urllib.request import urlopen

BASE_URL = os.environ.get("API_URL", "http://localhost:18080")


def get(path):
    try:
        with urlopen(BASE_URL + path, timeout=5) as resp:
            return resp.status, json.load(resp)
    except HTTPError as err:
        return err.code, json.load(err)


class ApiTest(unittest.TestCase):
    def test_health(self):
        self.assertEqual(get("/health"), (200, {"status": "ok"}))

    def test_discount(self):
        self.assertEqual(get("/discount?price=100&percent=15"), (200, {"total": 85.0}))

    def test_invalid_input_is_400(self):
        status, body = get("/discount?price=100&percent=150")
        self.assertEqual(status, 400)
        self.assertIn("percent", body["error"])


if __name__ == "__main__":
    unittest.main()
