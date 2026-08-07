"""Own JWT layer via PyJWT — no djangorestframework-simplejwt, no
django.contrib.auth token machinery."""
import uuid
import datetime
import jwt
from django.conf import settings

ALGORITHM = 'HS256'
ACCESS_LIFETIME = datetime.timedelta(minutes=30)
REFRESH_LIFETIME = datetime.timedelta(days=7)


def generate_tokens(user):
    now = datetime.datetime.utcnow()

    access_payload = {
        'user_id': user.id,
        'type': 'access',
        'iat': now,
        'exp': now + ACCESS_LIFETIME,
    }
    refresh_payload = {
        'user_id': user.id,
        'type': 'refresh',
        'jti': uuid.uuid4().hex,
        'iat': now,
        'exp': now + REFRESH_LIFETIME,
    }
    access = jwt.encode(access_payload, settings.SECRET_KEY, algorithm=ALGORITHM)
    refresh = jwt.encode(refresh_payload, settings.SECRET_KEY, algorithm=ALGORITHM)
    return access, refresh


def decode_token(token, expected_type='access'):
    payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
    if payload.get('type') != expected_type:
        raise jwt.InvalidTokenError('Wrong token type.')
    return payload