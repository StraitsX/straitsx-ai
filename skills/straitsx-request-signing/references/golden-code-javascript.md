# Golden Code — JavaScript/Node.js Ed25519 Request Signing

> This is the authoritative reference for JavaScript request signing. Do not generate cryptographic code from scratch — use this as the basis.

## Request Signing

```javascript
const crypto = require("crypto");
const fs = require("fs");
const { v4: uuidv4 } = require("uuid");

/**
 * Sign a StraitsX API request using Ed25519.
 *
 * @param {string} method - HTTP method (GET, POST, etc.)
 * @param {string} path - Request path (e.g., /api/v1/payments)
 * @param {Object|null} queryParams - Query parameters as key-value pairs
 * @param {Object|null} body - Request body object
 * @param {string} privateKeyPemPath - Path to Ed25519 private key PEM file
 * @returns {Object} Headers to include in the request
 */
function signRequest(method, path, queryParams, body, privateKeyPemPath) {
  // [SECURITY-CRITICAL: DO NOT MODIFY] — Load the Ed25519 private key
  const privateKeyPem = fs.readFileSync(privateKeyPemPath, "utf-8");
  const privateKey = crypto.createPrivateKey(privateKeyPem);

  // [SECURITY-CRITICAL: DO NOT MODIFY] — Generate timestamp and nonce
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const nonce = uuidv4();

  // [SECURITY-CRITICAL: DO NOT MODIFY] — Construct the canonical string
  // Format: METHOD\nPATH\nQUERY\nTIMESTAMP\nNONCE\nBODY
  let queryString = "";
  if (queryParams && Object.keys(queryParams).length > 0) {
    // Sort raw URL-encoded key=value pairs alphabetically
    const sortedPairs = Object.entries(queryParams)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
      .join("&");
    queryString = sortedPairs;
  }

  const bodyString = body ? JSON.stringify(body) : "";

  const canonicalString = `${method}\n${path}\n${queryString}\n${timestamp}\n${nonce}\n${bodyString}`;

  // [SECURITY-CRITICAL: DO NOT MODIFY] — Sign with Ed25519 private key
  const signature = crypto.sign(null, Buffer.from(canonicalString, "utf-8"), privateKey);
  const signatureB64 = signature.toString("base64");

  return {
    "X-PUBLIC-KEY-ID": process.env.PUBLIC_KEY_ID,
    "X-TIMESTAMP": timestamp,
    "X-NONCE": nonce,
    "X-SIGNATURE": signatureB64,
  };
}

module.exports = { signRequest };
```

## Auth Token Setup

```javascript
// Load the API key from environment variable
const apiKey = process.env.X_XFERS_APP_API_KEY;

// Standard headers for all API requests
const headers = {
  "X-XFERS-APP-API-KEY": apiKey,
  "Content-Type": "application/json",
};

// For signed requests, load the private key path
const privateKeyPath = process.env.PRIVATE_KEY_PATH;

// Use signRequest() from above to generate signing headers,
// then spread them into the headers object before making the request.
```
