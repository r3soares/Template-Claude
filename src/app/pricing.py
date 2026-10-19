"""Pricing rules — pure logic, no I/O, so it is unit-testable in isolation."""


def apply_discount(price: float, percent: float) -> float:
    """Return `price` reduced by `percent` (0–100), rounded to cents."""
    if price < 0:
        raise ValueError("price must be >= 0")
    if not 0 <= percent <= 100:
        raise ValueError("percent must be between 0 and 100")
    return round(price * (1 - percent / 100), 2)
