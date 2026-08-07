"""Replaces Django's AUTH_PASSWORD_VALIDATORS (which threw the
'too common' error) with rules you control."""
import re


def validate_password_strength(password: str):
    errors = []
    if len(password) < 8:
        errors.append('Password must be at least 8 characters long.')
    if not re.search(r'[A-Za-z]', password):
        errors.append('Password must contain at least one letter.')
    if not re.search(r'[0-9]', password):
        errors.append('Password must contain at least one number.')
    if errors:
        raise ValueError(' '.join(errors))