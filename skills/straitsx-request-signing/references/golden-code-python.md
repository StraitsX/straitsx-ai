# Golden Code — Python Ed25519 Request Signing

> This is the authoritative reference for Python request signing. Do not generate cryptographic code from scratch — use this as the basis.

## Request Signing

```python
import base64
import json
import os
import time
import uuid
from urllib.parse import urlencode

import nacl.signing  # PyNaCl library


def sign_request(method: str, path: str, query_params: dict | None, body: dict | None, private_key_pem_path: str) -> dict:
    """
    Sign a StraitsX API request using Ed25519.

    Returns a dict of headers to include in the request.
    """
    # [SECURITY-CRITICAL: DO NOT MODIFY] — Load the Ed25519 private key
    with open(private_key_pem_path, "rb") as f:
        private_key_data = f.read()
    signing_key = nacl.signing.SigningKey(private_key_data, encoder=nacl.encoding.RawEncoder)

    # [SECURITY-CRITICAL: DO NOT MODIFY] — Generate timestamp and nonce
    timestamp = str(int(time.time()))
    nonce = str(uuid.uuid4())

    # [SECURITY-CRITICAL: DO NOT MODIFY] — Construct the canonical string
    # Format: METHOD\nPATH\nQUERY\nTIMESTAMP\nNONCE\nBODY
    query_string = ""
    if query_params:
        # Sort raw URL-encoded key=value pairs alphabetically
        sorted_pairs = sorted(query_params.items())
        query_string = urlencode(sorted_pairs)

    body_string = ""
    if body:
        body_string = json.dumps(body, separators=(",", ":"))

    canonical_string = f"{method}\n{path}\n{query_string}\n{timestamp}\n{nonce}\n{body_string}"

    # [SECURITY-CRITICAL: DO NOT MODIFY] — Sign with Ed25519 private key
    signed = signing_key.sign(canonical_string.encode("utf-8"))
    signature_b64 = base64.b64encode(signed.signature).decode("utf-8")

    return {
        "X-PUBLIC-KEY-ID": os.environ["PUBLIC_KEY_ID"],
        "X-TIMESTAMP": timestamp,
        "X-NONCE": nonce,
        "X-SIGNATURE": signature_b64,
    }
```

## Auth Token Setup

```python
import os

# Load the API key from environment variable
api_key = os.environ["X_XFERS_APP_API_KEY"]

# Standard headers for all API requests
headers = {
    "X-XFERS-APP-API-KEY": api_key,
    "Content-Type": "application/json",
}

# For signed requests, load the private key path
private_key_path = os.environ["PRIVATE_KEY_PATH"]

# Use sign_request() from above to generate signing headers,
# then merge them into the headers dict before making the request.
```
