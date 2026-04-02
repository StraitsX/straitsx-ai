# Ed25519 Signature Verification

> This is a separate mechanism from HMAC-SHA256 callback verification. Use this when verifying Ed25519 signatures on request payloads, not for standard StraitsX callbacks.

## Python

```python
import base64

import nacl.signing
import nacl.encoding


def verify_ed25519_signature(payload: bytes, signature_b64: str, public_key_hex: str) -> bool:
    """
    Verify an Ed25519 signature on a payload.

    Args:
        payload: The raw payload as bytes.
        signature_b64: The base64-encoded Ed25519 signature.
        public_key_hex: The hex-encoded Ed25519 public key.

    Returns:
        True if the signature is valid, False otherwise.
    """
    try:
        # [SECURITY-CRITICAL: DO NOT MODIFY] — Decode the public key
        public_key_bytes = bytes.fromhex(public_key_hex)
        verify_key = nacl.signing.VerifyKey(public_key_bytes)

        # [SECURITY-CRITICAL: DO NOT MODIFY] — Decode the signature
        signature_bytes = base64.b64decode(signature_b64)

        # [SECURITY-CRITICAL: DO NOT MODIFY] — Verify (constant-time comparison handled by PyNaCl)
        verify_key.verify(payload, signature_bytes)
        return True
    except nacl.exceptions.BadSignatureError:
        return False
    except Exception:
        return False
```

## JavaScript/Node.js

```javascript
const crypto = require("crypto");

/**
 * Verify an Ed25519 signature on a payload.
 *
 * @param {Buffer} payload - The raw payload.
 * @param {string} signatureB64 - The base64-encoded Ed25519 signature.
 * @param {string} publicKeyHex - The hex-encoded Ed25519 public key.
 * @returns {boolean} True if the signature is valid, false otherwise.
 */
function verifyEd25519Signature(payload, signatureB64, publicKeyHex) {
  try {
    // [SECURITY-CRITICAL: DO NOT MODIFY] — Decode the public key
    const publicKeyBuffer = Buffer.from(publicKeyHex, "hex");
    const publicKey = crypto.createPublicKey({
      key: Buffer.concat([
        // Ed25519 public key DER prefix
        Buffer.from("302a300506032b6570032100", "hex"),
        publicKeyBuffer,
      ]),
      format: "der",
      type: "spki",
    });

    // [SECURITY-CRITICAL: DO NOT MODIFY] — Decode the signature
    const signatureBuffer = Buffer.from(signatureB64, "base64");

    // [SECURITY-CRITICAL: DO NOT MODIFY] — Verify (constant-time comparison handled by Node.js crypto)
    return crypto.verify(null, payload, publicKey, signatureBuffer);
  } catch (err) {
    return false;
  }
}

module.exports = { verifyEd25519Signature };
```
