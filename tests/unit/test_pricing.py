import unittest

from app.pricing import apply_discount


class ApplyDiscountTest(unittest.TestCase):
    def test_happy_path(self):
        self.assertEqual(apply_discount(100, 15), 85.0)

    def test_rounds_to_cents(self):
        self.assertEqual(apply_discount(9.99, 33), 6.69)

    def test_edge_zero_and_full_discount(self):
        self.assertEqual(apply_discount(50, 0), 50.0)
        self.assertEqual(apply_discount(50, 100), 0.0)

    def test_rejects_negative_price(self):
        with self.assertRaises(ValueError):
            apply_discount(-1, 10)

    def test_rejects_percent_out_of_range(self):
        for percent in (-0.1, 100.1):
            with self.subTest(percent=percent), self.assertRaises(ValueError):
                apply_discount(10, percent)


if __name__ == "__main__":
    unittest.main()
