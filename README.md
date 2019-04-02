# Overview
[BaseFEX](https://www.basefex.com) offers fully featured REST API and streaming WebSocket API.
* [REST API](#REST-API)
   * [Apply API keys](#Apply-API-keys)
   * [Authentication](#Authentication)
   * [Python Example](#rest-api-usage-python-example)
* [WebSocket API](#WebSocket-API)
   * [Python Example](#websocket-api-usage-python-example)

## REST API
We provide fully featured REST API to help you automate your trading.
* BaseFEX base endpoint: `https://api.basefex.com`
* Interactive Swagger REST API explorer: [https://api.basefex.com/explorer](https://api.basefex.com/explorer)

### Apply API keys
* Apply API keys from [https://www.basefex.com/account/keys](https://www.basefex.com/account/keys)
* You can apply API keys from the above link. In order to be able to create API Key,
Two-Factor Authentication via Google Authenticator or Authy app is required. After creating your key, store the private key safely and remember the key-id for it. You will need both to create an authorization token for API access. RSA signed [JWT](https://jwt.io/introduction/) token is used here.

### Authentication
#### Authorization spec:
```
Authorization: Bearer JWT.RS512.sign(privateKey, header, payload)
    where
     privateKey,keyId = Created from Account page
     header = {"alg": "RS512", "kid": "you api key"}
     payload = {"exp": expiration-time(epoch in seconds), "digest": http-payload-md5}
     http-payload-md5 = md5(${HTTP-METHOD}${PATH-WITH-QUERY-STRING}${HTTP-BODY}).toHexString().toUpperCase()
```
#### Signing detail with examples:
In your JWT token headers, make sure `alg` equals to `RS512` and `kid` equals to your private key id.

Sample JWT header:
```json
{"kid": "5a543ba4-2535-4933-0004-b38ca117d556",
 "alg": "RS512"}
```

For JWT digest payload:
- `HTTP-METHOD`: upper-case, `GET` | `POST`
- `PATH-WITH-QUERY-STRING`: PATH always starts with `/`, QUERY-STRING comes with `?` if exists. This fields comes as it is without `URL ENCODING`. For example: `"/balance?ABC=123&def=456"`
- `HTTP-BODY`: JSON-encoding String in request raw body, eg: `"{\"abc\":1,\"bar\":2}"`

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

Install some dependencies first with `pip install pyjwt cryptography requests`

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

### REST API Usage Python Example
```python
import requests
import json
```

#### Get account balance
```python
url = 'https://next-api.basefex.com/accounts'
auth_token = generate_token(key_id, private_key, "GET", 1584014794, "/accounts")
hed = {'authorization': 'Bearer ' + auth_token}
response = requests.get(url, headers=hed)
print(response.json())
```
=>
```json
{
  "cash": {
    "leverageUsageRate": 0.0,
    "available": 9.999371427,
    "orderMargin": 0.000628573,
    "balances": 10.0,
    "id": "5a5c77df-0a5b-4de7-0004-1482d7fd360f",
    "unrealizedPnl": 0,
    "overLoss": 0.0,
    "userId": "5a51dee2-1ceb-4c67-0004-0a9b2b5396a2",
    "marginBalances": 10.0,
    "marginUsageRate": 6.28573e-05,
    "currency": "BTC",
    "margin": 0.0
  },
  "positions": {
    "GRINBTC": {
      "marginRate": 0.01,
      "size": 0.0,
      "liquidatePrice": 0,
      "notional": 0.0,
      "id": "5a5c7825-10ea-4526-0004-f1732630e663",
      "markPrice": 0.000724,
      "buyingNotional": 0.0,
      "isCross": true,
      "feeRateMaker": 0.0,
      "entryPrice": 0,
      "sellingNotional": 0.0,
      "symbol": "GRINBTC",
      "riskLimit": 100.0,
      "totalPnl": 0.0,
      "unrealizedPnl": 0,
      "feeRateTaker": 0.0005,
      "orderMargin": 0.0,
      "sellingSize": 0.0,
      "realisedPnl": 0.0,
      "userId": "5a51dee2-1ceb-4c67-0004-0a9b2b5396a2",
      "buyingSize": 0.0,
      "leverage": 100.0,
      "margin": 0.0,
      "rom": 0
    },
    "BTCUSD": {
      "marginRate": 0.01,
      "size": 0.0,
      "liquidatePrice": 0,
      "notional": 0.0,
      "id": "5a5c7825-5b24-4434-0004-d1019822088b",
      "isCross": true,
      "feeRateMaker": 0.0,
      "entryPrice": 0,
      "sellingNotional": 0.0,
      "orderMargin": 0.000628573,
      "symbol": "BTCUSD",
      "riskLimit": 100.0,
      "markPrice": 3858.64,
      "totalPnl": 0.0,
      "unrealizedPnl": 0,
      "feeRateTaker": 0.0005,
      "buyingNotional": 0.057143,
      "sellingSize": 0.0,
      "realisedPnl": 0.0,
      "userId": "5a51dee2-1ceb-4c67-0004-0a9b2b5396a2",
      "leverage": 100.0,
      "buyingSize": 200.0,
      "margin": 0.0,
      "rom": 0
    }
  }
}
```

#### Get transactions
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

#### Place an order
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
{
  "ts": 1552444436078,
  "liquidateUserId": null,
  "size": 200,
  "id": "5a5d398b-9bb3-43be-0004-7097a8e2f9be",
  "side": "BUY",
  "meta": {
    "markPrice": 3858.64,
    "bestPrices": {
      "ask": 3856.5,
      "bid": 3856
    },
    "bestPrice": 3856.5
  },
  "filledNotional": 0,
  "status": "NEW",
  "isLiquidate": false,
  "reduceOnly": false,
  "type": "LIMIT",
  "symbol": "BTCUSD",
  "filled": 0,
  "conditional": null,
  "price": 3500,
  "avgPrice": 0,
  "notional": 0.057143,
  "userId": "5a51dee2-1ceb-4c67-0004-0a9b2b5396a2"
}
```

## WebSocket API
  You may subscribe to real-time changes through our websocket endpoints.
* The WebSocket base URL is `wss://ws.basefex.com`
* Interactive Swagger WebSocket API explorer [https://ws.basefex.com/explorer](https://ws.basefex.com/explorer)

### WebSocket API Usage Python Example
```python
import asyncio
import base64
import hashlib
import jwt
import requests
import ssl
import websockets
from cryptography.hazmat.primitives.serialization import load_der_private_key
from cryptography.hazmat.backends.openssl import backend

context = ssl.SSLContext(protocol=ssl.PROTOCOL_TLS)
async def receive(url, headers):
    async with websockets.connect(url, ssl=context, extra_headers=headers) as websocket:
        while not websocket.closed:
            data = await websocket.recv()
            print(data)
```

#### Subscribe Candlesticks
```python
candlestick_url = 'wss://ws.basefex.com/quotation/candlesticks/1MIN@BTCUSD'
asyncio.get_event_loop().run_until_complete(receive(candlestick_url, None))
```
=>
```json
[
  {
    "symbol": "BTCUSD",
    "type": "1min",
    "time": 1552628760,
    "open": 3860,
    "close": 3859.5,
    "high": 3860,
    "low": 3859.5,
    "volume": 17195,
    "n_trades": 3
  }
]
```

#### Subscribe Depth Book
```python
depth_url = 'wss://ws.basefex.com/quotation/depth@BTCUSD'
asyncio.get_event_loop().run_until_complete(receive(depth_url, None))
```
=>
```json
{
  "bids": {
    "3844": 27927
  },
  "last-price": 3860,
  "from": 547055,
  "best-prices": {
    "ask": 3860,
    "bid": 3859.5
  },
  "asks": {
    
  },
  "to": 547055
}
```

#### Subscribe Recent Trades
```python
trades_url = 'wss://ws.basefex.com/quotation/trades@BTCUSD'
asyncio.get_event_loop().run_until_complete(receive(trades_url, None))
```
=>
```json
[
  {
    "id": "5a5ffc13-b380-0000-0001-000000086607",
    "symbol": "BTCUSD",
    "price": 3860,
    "size": 15328,
    "matched_at": 1552629649,
    "side": "BUY"
  }
]
```

#### Subscribe Cash and Position
```python
# api key id from website
key_id = "5a54876c-04a9-4138-0004-5cb81fffffb8"

# api private key from website
private_key = "MIICdQI........"

auth_token = generate_token(key_id, private_key, "GET", 1584014794, "/stream")
headers = {'authorization': 'Bearer ' + auth_token}
stream_url = 'wss://ws.basefex.com/stream'
asyncio.get_event_loop().run_until_complete(receive(stream_url, headers))
```
=>
```json
{
  "cash": {
    "id": "5a5c77df-0a5b-4de7-0004-1482d7fd360f",
    "userId": "5a51dee2-1ceb-4c67-0004-0a9b2b5396a2",
    "currency": "BTC",
    "balances": 0,
    "available": 0,
    "margin": 0,
    "orderMargin": 0,
    "overLoss": 0,
    "leverage": 0,
    "marginBalances": 0,
    "unrealizedPnl": 0,
    "marginRate": 0,
    "positionMargin": 0
  },
  "positions": {
    "BTCUSD": {
      "id": "5a5c7825-5b24-4434-0004-d1019822088b",
      "userId": "5a51dee2-1ceb-4c67-0004-0a9b2b5396a2",
      "symbol": "BTCUSD",
      "isCross": true,
      "marginRate": 0.01,
      "feeRateTaker": 0.0005,
      "feeRateMaker": 0,
      "size": 0,
      "notional": 0,
      "margin": 0,
      "orderMargin": 0,
      "buyingSize": 0,
      "buyingNotional": 0,
      "sellingSize": 0,
      "sellingNotional": 0,
      "realisedPnl": 0,
      "totalPnl": 0,
      "markPrice": 3854.3,
      "riskLimit": 100,
      "leverage": 100,
      "rom": 0,
      "equity": 0,
      "value": 0,
      "entryPrice": 0,
      "risk": 0,
      "unrealizedPnl": 0,
      "liquidatePrice": 0
    }
  },
  "userId": "5a51dee2-1ceb-4c67-0004-0a9b2b5396a2",
  "trades": [
    
  ],
  "orders": [
    
  ]
}
```
