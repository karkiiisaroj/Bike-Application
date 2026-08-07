"""Zero dependency on django.contrib.auth.hashers — PBKDF2-HMAC-SHA256,
implemented directly against Python's hashlib."""
import hashlib
import hmac
import secrets

ITERATIONS = 260_000


def hash_password(raw_password: str) -> str:
    salt = secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac('sha256', raw_password.encode(), salt.encode(), ITERATIONS)
    return f"pbkdf2_sha256${ITERATIONS}${salt}${digest.hex()}"


def verify_password(raw_password: str, stored: str) -> bool:
    try:
        algorithm, iterations, salt, digest_hex = stored.split('$')
        iterations = int(iterations)
    except (ValueError, AttributeError):
        return False
    digest = hashlib.pbkdf2_hmac('sha256', raw_password.encode(), salt.encode(), iterations)
    return hmac.compare_digest(digest.hex(), digest_hex)