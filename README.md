# API usage
You can apply API keys from Account & Preferences page. In order to be able to create API Key,
Two-Factor Authentication via Google Authenticator or Authy app is required. After creating your key, store the private key safely and remember the key-id for it. You will need both to create an authorization token for API access. RSA signed [JWT](https://jwt.io/introduction/) token is used here.

## Apply API keys from [here](https://www.basefex.com/account/keys)

### authorization spec:
```
Authorization: Bearer JWT.RS512.sign(privateKey, header, payload)
    where
     privateKey,keyId = Created from Account page
     header = {"alg": "RS512", "kid": "you api key"}
     payload = {"exp": expiration-time(epoch in seconds), "digest": http-payload-md5}
     http-payload-md5 = md5(${HTTP-METHOD}${PATH-WITH-QUERY-STRING}${HTTP-BODY}).toHexString().toUpperCase()
```

In your JWT token headers, make sure `alg` equals to `RS512` and `kid` equals to your private key id.

Sample JWT header:
```json
{"kid": "5a543ba4-2535-4933-0004-b38ca117d556",
 "alg": "RS512"}
```

For JWT digest payload:
- HTTP-METHOD: upper-case, `GET` | `POST`
- PATH-WITH-QUERY-STRING: PATH always starts with `/`, QUERY-STRING comes with `?` if exists. This fields comes as it is without `URL ENCODING`. For example: `"/balance?ABC=123&def=456"`
- HTTP-BODY: JSON-encoding String in request raw body, eg: `"{\"abc\":1,\"bar\":2}"`

raw `digest` before MD5 example: `POST/balance/user?q=foo{\"abc\":1,\"bar\":2}`

The private key we gave you is encoded in Base64. After decoding it in Base64, you will get the key in PKCS#8 DER format.
Ways to get your private key in Java:
```java
byte[] bytes = "private key string here".getBytes("UTF-8");

byte[] privKeyByteArray = Base64.getDecoder().decode(bytes);

PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(privKeyByteArray);

KeyFactory keyFactory = KeyFactory.getInstance("RSA");

PrivateKey myPrivKey = keyFactory.generatePrivate(keySpec);
```

Or in python
```python
import base64
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.backends.openssl import backend

key_str = "your private key string"
der = base64.b64decode(key_str)
key = load_der_private_key(der, password=None, backend=backend)
```

Use the PEM private key to sign your JWT token with payload. Create your Bearer authorization in http header: `{"authorization" "Bearer xxxxxxxxxxxxxxxxxxx"}`

Sample python code for generating token:
```python
import base64
import jwt
import hashlib
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.backends.openssl import backend

# api key id from website
key_id = "5a54876c-04a9-4138-0004-5cb81fffffb8"

# api private key from website
private_key = "MIICdQI........"

def create_digest(method, uri, query_str, body):
    data = method + uri + query_str + body
    return hashlib.md5(data.encode()).hexdigest()

def generate_token(key_id, private_key, method, exp, uri="/", query_str="", body=""):
    digest = create_digest(method, uri, query_str, body)
    der = base64.b64decode(private_key)
    pem_key = load_der_private_key(der, password=None, backend=backend)
    jwt_encode = jwt.encode({'digest': digest, 'exp': exp}, pem_key, algorithm='RS512', headers={'kid': key_id})
    return jwt_encode.decode("utf-8")
```

Sample usage:
```python
#
# GET with complex querystring
#
generate_token(key_id, private_key, "GET", "id=5a24e489-849c-fdd7-0002-2047993c11a3&limit=1&page=2")

```

```python
#
# POST with body
#
generate_token(key_id, private_key, "POST", "", "{\"price\":3500,\"size\":200}")
```

# API Usage Python Example
```python
import requests
import json
```

### Get account balance
```python
url = 'https://next-api.basefex.com/accounts'
auth_token = generate_token(key_id, private_key, "GET", 1584014794, "/accounts")
hed = {'authorization': 'Bearer ' + auth_token}
response = requests.get(url, headers=hed)
print(response.json())
```
=>
```json
{'cash': {'leverageUsageRate': 0.0, 'available': 9.999371427, 'orderMargin': 0.000628573, 'balances': 10.0, 'id': '5a5c77df-0a5b-4de7-0004-1482d7fd360f', 'unrealizedPnl': 0, 'overLoss': 0.0, 'userId': '5a51dee2-1ceb-4c67-0004-0a9b2b5396a2', 'marginBalances': 10.0, 'marginUsageRate': 6.28573e-05, 'currency': 'BTC', 'margin': 0.0}, 'positions': {'GRINBTC': {'marginRate': 0.01, 'size': 0.0, 'liquidatePrice': 0, 'notional': 0.0, 'id': '5a5c7825-10ea-4526-0004-f1732630e663', 'markPrice': 0.000724, 'buyingNotional': 0.0, 'isCross': True, 'feeRateMaker': 0.0, 'entryPrice': 0, 'sellingNotional': 0.0, 'symbol': 'GRINBTC', 'riskLimit': 100.0, 'totalPnl': 0.0, 'unrealizedPnl': 0, 'feeRateTaker': 0.0005, 'orderMargin': 0.0, 'sellingSize': 0.0, 'realisedPnl': 0.0, 'userId': '5a51dee2-1ceb-4c67-0004-0a9b2b5396a2', 'buyingSize': 0.0, 'leverage': 100.0, 'margin': 0.0, 'rom': 0}, 'BTCUSD': {'marginRate': 0.01, 'size': 0.0, 'liquidatePrice': 0, 'notional': 0.0, 'id': '5a5c7825-5b24-4434-0004-d1019822088b', 'isCross': True, 'feeRateMaker': 0.0, 'entryPrice': 0, 'sellingNotional': 0.0, 'orderMargin': 0.000628573, 'symbol': 'BTCUSD', 'riskLimit': 100.0, 'markPrice': 3858.64, 'totalPnl': 0.0, 'unrealizedPnl': 0, 'feeRateTaker': 0.0005, 'buyingNotional': 0.057143, 'sellingSize': 0.0, 'realisedPnl': 0.0, 'userId': '5a51dee2-1ceb-4c67-0004-0a9b2b5396a2', 'leverage': 100.0, 'buyingSize': 200.0, 'margin': 0.0, 'rom': 0}}}
```

### Get transactions
```python
url = 'https://next-api.basefex.com/accounts/transactions?limit=10'
auth_token = generate_token(key_id, private_key, "GET", 1584014794, "/accounts/transactions", "?limit=10")
hed = {'authorization': 'Bearer ' + auth_token}
response = requests.get(url, headers=hed)
print(response.json())
```
=>
```json
[]
```

### Place an order
```python
payload = {'price': 3500, 'size': 200, 'type': 'LIMIT', 'side': 'BUY', 'symbol': 'BTCUSD'}
url = 'https://next-api.basefex.com/orders'
auth_token = generate_token(key_id, private_key, "POST", 1584014794, "/orders", "", json.dumps(payload))
hed = {'authorization': 'Bearer ' + auth_token, 'Content-Type': 'application/json'}
response = requests.post(url, headers=hed, json=payload)
print(response.json())
```
=>
```json
{"ts": 1552444436078, "liquidateUserId": null, "size": 200, "id": "5a5d398b-9bb3-43be-0004-7097a8e2f9be", "side": "BUY", "meta": {"markPrice": 3858.64, "bestPrices": {"ask": 3856.5, "bid": 3856}, "bestPrice": 3856.5}, "filledNotional": 0, "status": "NEW", "isLiquidate": False, "reduceOnly": False, "type": "LIMIT", "symbol": "BTCUSD", "filled": 0, "conditional": null, "price": 3500, "avgPrice": 0, "notional": 0.057143, "userId": "5a51dee2-1ceb-4c67-0004-0a9b2b5396a2"}
```

# Interactive REST API Explorer
For a list of endpoints and return types, view the REST documentation in the [API Explorer](https://api.basefex.com/explorer).
