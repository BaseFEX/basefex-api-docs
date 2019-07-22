
| [English](./api-doc_en.md) | [中文简体](./api-doc_zh.md) |
| -------------------------- | ----------------------- |

# REST API and WebSocket

<!-- toc -->

# Overview

  - API Keys and Authentication
      - [Authentication](#open-api-authentication)
  - REST API
      - [Accounts](#open-api-accounts)
      - [Orders](#open-api-orders)
      - [Trades](#open-api-trades)
      - [Positions](#open-api-positions)
      - [Misc](#open-api-misc)
  - WebSocket
      - [Websocket Subscription](#open-api-ws)

## Swagger

  - TestNet Environment:
    <https://testnet-api.basefex.com/explorer/index.html#/>
  - Official Trading Environment:
    <https://api.basefex.com/explorer/index.html#/>

## <span id="open-api-authentication"> API Keys and Authorization </span>

### Generate API Keys

Generate new API keys from <https://www.basefex.com/account/keys>. May
need two-factor authentication via Google Authenticator or Authy. You
must store your secret carefully, and use this secret to genenrate
signature along with your every request.

### Authorization

The request header must contains expires, your api key id and the
signature you computed. Signatures are computed by the `HmacSHA256`
algorithm and most programming languages have their implimentations of
this algorithm. You need `api key`, `HTTP request method`, `request
url(relative path)`, `expires` and `request body` to generate
signatures. And the `request body` is json string, or empty string when
`HTTP request method` is `GET`.

##### Headers Must Have

  - `api-expires`: expires, a unix timestamp. Unit is seconds. For
    instance, timestamp `1562831554` refers to `2019-07-11 07:52:34`
    (UTC time), compared to the time on basefex server, if it does not
    expire then grant access.

  - `api-key`: id of api key.

  - `api-signature`: computed base `hex(HMAC_SHA256(apiSecret,
    http_method + path + expires + data))`. See details in Python
    example
below.

##### Signature generation example

``` python
apiKey = '5afd4095-f1fb-41d0-0005-1a0048ffe468'            # id of api key
apiSecret = 'OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is=' # api secret

http_method = 'GET'
path = '/accounts'
expires = 1563148118 # unix timestamp, refers to 2019-07-14 23:28:38 (UTC)
data = ''                                                   # empty request body

# HEX(HMAC_SHA256(apiSecret, 'GET/accounts1563148118'))
# Computed signature is:
# '8b22cc3707d740c8fd43d97d39a52ad1bff3fc35e247fd4baac5e00824192c0c'
signature = HEX(HMAC_SHA256(apiSecret, http_method + path + str(expires) + data))
```

Or you can visit
[这个网站](https://www.freeformatter.com/hmac-generator.html) to
check if your are computed the right signature.

##### Signature generation in Python

``` python
from datetime import datetime
import hashlib
import hmac
from urllib.parse import urlparse
import json

# The algorithm is: hex(HMAC_SHA256(secret, http_method + path + expires + data))
# Upper-cased http_method, relative request path, unix timestamp expires.
# data is json string
def generate_signature(secret, http_method, url, expires, data):
    # parse relative path
    parsedURL = urlparse(url)
    path = parsedURL.path
    if parsedURL.query:
        path = path + '?' + parsedURL.query

    if isinstance(data, (bytes, bytearray)):
        data = data.decode('utf8')

    print("Computing HMAC: %s" % http_method + path + str(expires) + data)
    message = http_method + path + str(expires) + data

    signature = hmac.new(bytes(secret, 'utf8'), bytes(message, 'utf8'), digestmod=hashlib.sha256).hexdigest()
    return signature

# api secret
secret = "OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is="
expires = 1563148118
# Or expires after some moment
# Below expires in 5 seconds
# timestamp = datetime.now().timestamp()
# expires = int(round(timestamp) + 5)

print(generate_signature(secret, 'GET', '/accounts', expires, ''))
```

#### Request example

GET请求

``` python
key_id = '5afd4095-f1fb-41d0-0005-1a0048ffe468'         # replace with your api key id 
secret = 'OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is=' # replace with your apk secret
path = '/accounts'                                      # relative path
url = 'https://api.basefex.com' + path
timestamp = datetime.now().timestamp()
expires = int(round(timestamp) + 5)                     # expires in 5 seconds
data = ''                                               # HTTP GET, empty string
auth_token = generate_signature(secret, "GET", path, expires, data)  
hed = {'api-expires':str(expires),'api-key':key_id,'api-signature':str(auth_token)}
response = requests.get(url, headers=hed)
print(response.json())
```

POST请求

``` python
key_id = '5afd0a44-4b68-4e4a-0005-10c406964844'         # replace with your api key id
secret = "3gA/QTBW3F35pl/oaeONMCA3Wnh9MDrq9728/HyPDu8=" # replace with your apk secret
path = '/orders'                                        # relative path
url = 'https://api.basefex.com' + path
timestamp = datetime.now().timestamp()
expires = int(round(timestamp) + 5)                     # expires in 5 seconds
data = {
    "size": 200,
    "symbol": "BTCUSD",
    "type": "LIMIT",
    "side": "BUY",
    "price": 3750.5,
    "reduceOnly": False,
    "conditional": {
        "type": "REACH",
        "price": 3750.5,
        "priceType": "MARKET_PRICE"
    }}                                             
print(json.dumps(data))
auth_token = generate_signature(
    secret, "POST", path, expires, json.dumps(data))   
hed = {'api-expires': str(expires), 'api-key': key_id,'api-signature': str(auth_token)}
response = requests.post(url, headers=hed, json=data)  # HTTP POST, pass headers and json parameters
print(response.json())
```

##### Rate Limit

`REST API` limit to 180 per minite, `WebSockets` limit to 60 per minite.
And three headers with every response indicate your request limit
status.

``` js
x-ratelimit-limit      # limit per minite
x-ratelimit-remaining  # remaining times
x-ratelimit-reset      # next timestamp when your can request(if reach limit)
```

Please use bulk API like `place orders in batches`,`cancel orders in
batches`, etc. to optimise your request limit.

## REST API

## <span id="open-api-accounts"> Accounts </span>

### Get Cash and Position Detail

##### URL

<https://api.basefex.com/accounts>

##### HTTP Request Method

> GET

##### Request Parameters

No parameter needed.

##### Request Example URL

<https://api.basefex.com/accounts>

##### Response Example

``` js
{
  "cash": {                                            
    "orderMargin": 0.0983953764,                       
    "balances": 1000,                                  
    "marginRate": 0,                                   
    "userId": "5aec525e-335d-4724-0005-20153b361f89",  
    "leverage": 0,                                     
    "marginBalances": 1000,                            
    "positionMargin": 0,                               
    "available": 999.9016046236,                       
    "unrealizedPnl": 0,                                
    "id": "5aec8f3b-ea46-4eaa-0005-639ddae22e5f",      
    "currency": "BTC",                               // which currency, BTC    
    "margin": 0                                        
  },
  "positions": {
    "ETHXBT": {                                        
      "markPrice": 0.02608751,                         
      "value": 0,                                      
      "size": 0,                                       
      "liquidatePrice": 0,                             
      "risk": 0,                                       
      "symbol": "ETHXBT",                              
      "notional": 0,                                   
      "userId": "5aec525e-335d-4724-0005-20153b361f89",
      "buyingNotional": 0,                             
      "isCross": true,                                 
      "feeRateMaker": 0,                               
      "entryPrice": 0,                                 
      "sellingNotional": 0,                            
      "marginRate": 0.02,                              
      "id": "5aec8f3f-ad95-43a7-0005-c80b43cdb509",    
      "seqNo": null,                                   
      "leverage": 50,                                  
      "totalPnl": 0,                                   
      "unrealizedPnl": 0,                              
      "feeRateTaker": 0.002,                           
      "orderMargin": 0,                                
      "sellingSize": 0,                                
      "realisedPnl": 0,                                
      "equity": 0,                                     
      "buyingSize": 0,                                 
      "riskLimit": 50,                                 
      "margin": 0,                                     
      "rom": 0                                         
    },
    ...
  },
  {
    "cash": {                                          // 
      "currency": "USDT",                              // which currency, USDT
      "balances": 1,                                   // 
      "marginRate": 0,                                 // 
      "userId": "5aec525e-335d-4724-0005-20153b361f89",// 
      "id": "5af05f79-bff6-4d6a-0005-30bcdff8bd36",    // 
      "leverage": 0,                                   // 
      "positionMargin": 0,                             // 
      "unrealizedPnl": 0,                              // 
      "orderMargin": 0,                                // 
      "marginBalances": 1,                             // 
      "available": 1,                                  // 
      "margin": 0                                      // 
    },
    "positions": []                                    // positions
  } 
}
```

<!--
### Get Account Equity Information

##### URL

https://api.basefex.com/accounts/equity

##### HTTP Request Method

> GET

##### Request Parameters

Not any.

##### Request Example URL

https://api.basefex.com/accounts/equity

##### Response Example

```js
{
  "equity": {
    "available": 0.0000810079987298,  // available balances, unit: BTC
    "positionMargin": 0,              
    "marginBalances": 6.5360025e-9,   
    "marginBalancesBtc": 6.5360025e-9,
    "unrealizedPnl": 0                
  }
}
``` -->

### Get Deposit and Withdrawal History

##### URL

<https://api.basefex.com/accounts/transactions>

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required | Type   | Note                                          |
| ---------- | -------- | ------ | --------------------------------------------- |
| type       |          | string | Transaction type，`DEPOSIT` or `WITHDRAW`      |
| id         |          | string | Order id of previous response for pagination. |
| limit      |          | number | Response size limit.                          |

##### Request Example URL

<https://api.basefex.com/accounts/transactions?type=DEPOSIT&limit=30>

##### Response Example

``` js
[
  {
    "address": "2N2BUEAqDH1mhYe2tVy1tRPda9jY4KniyjB",                                  
    "foreignTxId": "a862ade7c3a642968b1f1e1412701fd3c854397fa2706b57a9ce1838d3bfddf7", 
    "userId": "5aec525e-335d-4724-0005-20153b361f89",                                  
    "status": "NEW",                                                                       
    "id": "5aeeeba7-2843-f607-0005-2fdaac7eda8f",                                      
    "subtype": null,                                                                   
    "amount": 0.0653564,                                                               
    "balances": null,                                                                  
    "ts": 1562221911201,                                                               
    "type": "DEPOSIT",                                                                 
    "readableId": null,                                                                
    "audit": null,                                                                     
    "fee": 0,                                                                          
    "note": null,                                                                      
    "currency": "BTC"                                                                  
  }
]
```

### Count Transactions

##### URL

<https://api.basefex.com/accounts/transactions/count>

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required | Type   | Note                                     |
| ---------- | -------- | ------ | ---------------------------------------- |
| type       |          | string | Transaction type，`DEPOSIT` or `WITHDRAW` |

##### Request Example URL

<https://api.basefex.com/accounts/transactions/count?type=DEPOSIT>

##### Response Example

``` js
{
  "count": 1
}
```

## <span id="open-api-orders"> Orders </span>

<!-- GET /orders/{id} -->

<!-- Done -->

### Get Order Detail

Get order information by order
id.

##### URL

[https://api.basefex.com/orders/{id}](https://api.basefex.com/orders/%7Bid%7D)

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | required             | Type   | Note     |
| ---------- | -------------------- | ------ | -------- |
| id         | :white\_check\_mark: | string | Order id |

##### URL Request Example

<https://api.basefex.com/orders/5aec8f9f-1609-4e54-0005-86e30e0cb1c6>

##### Response Example

``` js
{
  "liquidateUserId": null,
  "side": "BUY",                                    // 
  "meta": {                                         // 
    "bestPrice": null,                              // 
    "markPrice": 10051.43,                          // 
    "bestPrices": {                                 // 
      "ask": null,                                  // 
      "bid": null                                   // 
    }                                               // 
  },                                                // 
  "userId": "5aec525e-335d-4724-0005-20153b361f89", // 
  "filledNotional": 0,                              // 
  "ts": 1562063567960,                              // 
  "notional": 0.102512,                             // 
  "status": "NEW",                                  // Order status
  "isLiquidate": false,                             // 
  "reduceOnly": false,                              //
  "type": "LIMIT",                                  // Order type
  "symbol": "BTCUSD",                               // Contract type
  "seqNo": null,                                    // 
  "filled": 0,                                      // 
  "conditional": null,                              // 
  "id": "5aec8f9f-1609-4e54-0005-86e30e0cb1c6",     // 
  "size": 1000,                                     // Contract amount
  "avgPrice": 0,                                    // 
  "price": 9755                                     // 
}                                                     
```

<!-- POST /orders -->

<!-- Done -->

### Place Order

Place single
order.

##### URL

<https://api.basefex.com/orders>

##### HTTP Request Method

> POST

##### Request Parameters

| Parameters  | Required             | Type    | Note                                                                                                                                                                   |
| ----------- | -------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| size        | :white\_check\_mark: | number  | Contract amount                                                                                                                                                        |
| symbol      | :white\_check\_mark: | string  | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT`    |
| type        | :white\_check\_mark: | string  | Order type, includes `LIMIT`, `MARKET`, `IOC`, `FOK`, `POST_ONLY`                                                                                                      |
| side        | :white\_check\_mark: | string  | `BUY` or `SELL`                                                                                                                                                        |
| price       |                      | number  | Order price                                                                                                                                                            |
| reduceOnly  |                      | boolean | A Reduce Only Order will only reduce your position, not increase it. If this order would increase your position, it is amended down or canceled such that it does not. |
| conditional |                      | object  | currently conditional type only have one option `REACH`, price types includes `MARK_PRICE`,`INDEX_PRICE`,`MARKET_PRICE`                                                |

##### URL Request Example

<https://api.basefex.com/orders>

##### Request Body Example

``` js
{
  "size": 1,
  "symbol": "BTCUSD",
  "type": "LIMIT",
  "side": "BUY",
  "price":8000,
  "reduceOnly": false,
  "conditional": {
    "type": "REACH",
    "price": 8000,
    "priceType": "MARKET_PRICE"
  }
}
```

##### Response Example

``` js
{
  "meta": null,                                     
  "reduceOnly": false,                              
  "symbol": "BTCUSD",                               
  "type": "LIMIT",                                  
  "userId": "5aec525e-335d-4724-0005-20153b361f89", 
  "liquidateUserId": null,                          
  "size": 1,                                        
  "notional": 0,                                    
  "status": "UNTRIGGERED",                          
  "id": "5aed7b45-5d19-40f2-0005-ca49d01f33e3",     
  "side": "BUY",                                    
  "filledNotional": 0,                              
  "seqNo": null,                                    
  "filled": 0,                                      
  "price": 8000,                                    
  "conditional": {                                  
    "type": "REACH",                                
    "priceType": "MARKET_PRICE",                    
    "price": 8000                                   
  }
}
```

<!-- DELETE /orders/{id} -->

<!-- Done -->

### Cancel Order

Cancel one order by order
id.

##### URL

[https://api.basefex.com/orders/{id}](https://api.basefex.com/orders/%7Bid%7D)

##### HTTP Request Method

> DELETE

##### Request Parameters

| Parameters | Required             | Type   | Note     |
| ---------- | -------------------- | ------ | -------- |
| id         | :white\_check\_mark: | string | order id |

##### Request URL Example

<https://api.basefex.com/orders/5aec8f9f-1609-4e54-0005-86e30e0cb1c6>

No response
content

<!-- GET /orders -->

<!-- Done -->

### Get Order List

##### URL

<https://api.basefex.com/orders>

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required | Type   | Note                                                                                                                                                                |
| ---------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     |          | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id         |          | string | Order id of previous response for pagination.                                                                                                                       |
| type       |          | string | Order types, includes `LIMIT`, `MARKET`, `IOC`, `FOK`, `POST_ONLY`                                                                                                  |
| side       |          | string | `BUY` or `SELL`                                                                                                                                                     |
| status     |          | string | Order status, includes `NEW`, `PARTIALLY_FILLED`, `PARTIALLY_CANCELED`, `CANCELED`, `REJECTED`, `FILLED`, `UNTRIGGERED`, `PENDING_CANCEL`, `TRIGGERED`              |
| opt        |          | string | `TRIGGERED` or `LIQUIDATE`                                                                                                                                          |
| limit      |          | number | Response size limit.                                                                                                                                                |

If no parameter specified, then get all
orders.

##### Request URL Example

<https://api.basefex.com/orders?symbol=BTCUSD&type=LIMIT&side=BUY&status=NEW&limit=30>

##### Response Example

``` js
[
  {
    "liquidateUserId": null,                           
    "id": "5aed94fc-703e-42a2-0005-578d4c468767",     
    "ts": 1562132083136,                              // timestamp
    "side": "BUY",                                    
    "userId": "5aec525e-335d-4724-0005-20153b361f89", 
    "filledNotional": 0,                              
    "notional": 0.102512,                             
    "status": "NEW",                                  
    "isLiquidate": false,                             
    "reduceOnly": false,                              
    "type": "LIMIT",                                  
    "symbol": "BTCUSD",                               
    "seqNo": null,                                    
    "filled": 0,                                      
    "conditional": null,                              
    "size": 1000,                                     
    "avgPrice": 0,                                    
    "price": 9755,                                    
    "meta": {                                         
      "bestPrice": 11311,                             
      "markPrice": 11536.1075491,                     
      "bestPrices": {                                 
        "ask": 11311,                                 
        "bid": 11305.5                                
      }
    }
  }
]
```

<!-- POST /orders/batch -->

### Place Order in Batches

##### URL

<https://api.basefex.com/orders/batch>

##### HTTP Request Method

> POST

##### Request Parameters

| Parameters | Required             | Type   | Note                                                                                                                                                                |
| ---------- | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     | :white\_check\_mark: | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| orders     | :white\_check\_mark: | list   | Explanations below                                                                                                                                                  |

##### Request Example URL

<https://api.basefex.com/orders/batch>

##### Request Body Example

``` js
{
  "symbol": "BTCUSD",
  "orders": [             // a list
    {
      "price": 11234,     // price of the contract, is a number
      "size": 200,        // contract size, is a number
      "side": "BUY"       // BUY or SELL, is a string
    }
  ]
}
```

##### Response Example

``` js
[
  {
    "liquidateUserId": null,                           
    "price": 11234,                                    
    "size": 200,                                       
    "id": "5aedb78e-6641-4d00-0005-2b2439f84663",      
    "userId": "5aec525e-335d-4724-0005-20153b361f89",  
    "filledNotional": 0,                               
    "ts": 1562141145497,                               // timestamp
    "status": "NEW",                                   
    "isLiquidate": false,                              
    "reduceOnly": false,                               
    "type": "LIMIT",                                   
    "symbol": "BTCUSD",                                
    "seqNo": null,                                     
    "filled": 0,                                       
    "conditional": null,                               
    "side": "BUY",                                     
    "avgPrice": 0,                                     
    "meta": {                                          
      "markPrice": 11303.14,                           
      "bestPrices": {                                  
        "ask": 11311,                                  
        "bid": 11305.5                                 
      },                                               
      "bestPrice": 11305.5                             
    },                                                 
    "notional": 0.017804                               
  }                                                    
]
```

<!-- DELETE /orders -->

<!-- Deprecate -->

<!-- ### 批量撤销订单

##### URL

https://api.basefex.com/orders

##### HTTP Request Method

> DELETE

https://api.basefex.com/orders?symbol=BTCUSD&side=BUY

##### Request Parameters

| Parameters | Required | Type   | Note                                              |
|------------|----------|--------|---------------------------------------------------|
| symbol     |          | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| side       |          | string | `BUY` `SELL`                                      |

No response content -->

### Cancel Order in Batches

##### URL

<https://api.basefex.com/orders/batch>

##### HTTP Request Method

> DELETE

##### Request Parameters

| Parameters | Required | Type   | Note                                                                                                                                                                |
| ---------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     |          | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| ids        |          | list   | List of order ids                                                                                                                                                   |

##### Request Example URL

<https://api.basefex.com/orders/batch>

##### Request Body Example

``` js
{
  "symbol": "BTCUSD",
  "ids": [
    "5aedb78e-6641-4d00-0005-2b2439f84663",
    "5aed7b45-5d19-40f2-0005-ca49d01f33e3"
  ]
}
```

No response
content

<!-- GET /orders/opening -->

<!-- Done -->

### Get Active Order List

##### URL

<https://api.basefex.com/orders/opening>

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required | Type   | Note                                                                                                                                                                |
| ---------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     |          | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id         |          | string | Order id of previous response for pagination.                                                                                                                       |
| limit      |          | number | Response limit per request                                                                                                                                          |

##### URL Request Example

<https://api.basefex.com/orders/opening?symbol=BTCUSD&limit=30>

##### Response Example

``` js
[
  {
    "liquidateUserId": null,                          
    "ts": 1562125342068,                              // timestamp
    "size": 1,                                        
    "notional": 0,                                    
    "side": "BUY",                                    
    "userId": "5aec525e-335d-4724-0005-20153b361f89", 
    "filledNotional": 0,                              
    "isLiquidate": false,                             
    "reduceOnly": false,                              
    "type": "LIMIT",                                  
    "symbol": "BTCUSD",                               
    "seqNo": null,                                    
    "filled": 0,                                      
    "meta": null,                                     
    "status": "UNTRIGGERED",                          
    "avgPrice": 0,                                    
    "price": 8000,                                    
    "conditional": {                                  
      "type": "REACH",                                
      "price": 8000,                                  
      "priceType": "MARKET_PRICE"                     
    },                                                
    "id": "5aed7b45-5d19-40f2-0005-ca49d01f33e3"      
  }                                                     
]                                                     
```

<!-- GET /orders/count -->

<!-- Done -->

### Count Orders

##### URL

<https://api.basefex.com/orders/count>

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required | Type   | Note                                                                                                                                                                |
| ---------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     |          | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id         |          | string | Order id of previous response for pagination.                                                                                                                       |
| type       |          | string | one of `LIMIT` `MARKET` `IOC` `FOK` `POST_ONLY`                                                                                                                     |
| side       |          | string | `BUY` or `SELL`                                                                                                                                                     |
| status     |          | string | Order status, includes `NEW`, `PARTIALLY_FILLED`, `PARTIALLY_CANCELED`, `CANCELED`, `REJECTED`, `FILLED`, `UNTRIGGERED`, `PENDING_CANCEL`, `TRIGGERED`              |
| opt        |          | string | `TRIGGERED` `LIQUIDATE`                                                                                                                                             |

##### Request Example URL

<https://api.basefex.com/orders/count?symbol=BTCUSD&type=LIMIT&side=BUY&status=NEW>

##### Response Example

``` js
{
  "count": 1             
}
```

<!-- GET /orders/opening/count -->

<!-- Done -->

### Count Active Orders

##### URL

<https://api.basefex.com/orders/opening/count>

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required | Type   | Note                                                                                                                                                                |
| ---------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     |          | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### Request Example URL

<https://api.basefex.com/orders/opening/count?symbol=BTCUSD>

##### Response Example

``` js
{
  "count": 2                 
}
```

## <span id="open-api-trades"> Trades </span>

### Get Trade List

##### URL

<https://api.basefex.com/trades>

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required | Type   | Note                                                                                                                                                                |
| ---------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     |          | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id         |          | string | Order id of previous response for pagination.                                                                                                                       |
| limit      |          | number | Response size limit.                                                                                                                                                |
| side       |          | string | `BUY`, `SELL` or `FUNDING`(triggered every 8 hours)                                                                                                                 |
| order-id   |          | string | Order id                                                                                                                                                            |

##### Request Example URL

<https://api.basefex.com/trades?limit=30&side=SELL>

##### Response Example

``` js
[
  {
    "fee": 0.00006200177148,                           
    "symbol": "BTCUSD",                                
    "feeRate": 0.0007,                                 
    "size": 1000,                                      
    "ts": 1562244089804,                               
    "notional": 0.08857395925,                         
    "orderId": "5aef4041-ee43-4a60-0005-705a0f1edcb4", 
    "id": "5aef4041-f300-0000-0001-00000000001b",      
    "side": "SELL",                                    
    "order": {                                         
      "id": "5aef4041-ee43-4a60-0005-705a0f1edcb4",    
      "type": "LIMIT",                                 
      "size": 1000,                                    
      "price": 11290                                   
    },
    "price": 11290
  }
]
```

### Get Count of Trades

##### URL

<https://api.basefex.com/trades/count>

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required | Type   | Note                                                                                                                                                                |
| ---------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     |          | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id         |          | string | Order id of previous response for pagination.                                                                                                                       |
| limit      |          | number | Response size limit.                                                                                                                                                |
| side       |          | string | `BUY`, `SELL` or `FUNDING`(triggered every 8 hours)                                                                                                                 |
| order-id   |          | string | Order id                                                                                                                                                            |

##### Request Example URL

<https://api.basefex.com/trades/count?symbol=BTCUSD&limit=30&side=BUY>

##### Response Example

``` js
{
  "count": 3      
}
```

## <span id="open-api-positions"> Positions </span>

### Adjust Leverage

##### URL

[https://api.basefex.com/positions/{symbol}/margin](https://api.basefex.com/positions/%7Bsymbol%7D/margin)

##### HTTP Request Method

> PUT

##### Request Parameters

| Parameters | Required             | Type    | Note                                                                                                                                                                |
| ---------- | -------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     | :white\_check\_mark: | string  | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| margin     |                      | number  |                                                                                                                                                                     |
| leverage   |                      | number  | Leverage, valid when isCross to be true                                                                                                                             |
| isCross    |                      | boolean | true(cross margin) or false                                                                                                                                         |

##### Request Example URL

<https://api.basefex.com/positions/BTCUSD/margin>

##### Request Body Example

``` js
{
  "margin": 0,
  "leverage": 0,
  "isCross": true
}
```

##### Response Example

``` js
{
  "feeRateMaker": -0.0002,                             
  "id": "5aec8f3f-9846-41af-0005-1b306eeb533a",        
  "value": 0,                                          
  "marginRate": 0.01,                                  
  "size": 0,                                           
  "liquidatePrice": 0,                                 
  "markPrice": 11303.14,                               
  "risk": 0,                                           
  "notional": 0,                                       
  "userId": "5aec525e-335d-4724-0005-20153b361f89",    
  "buyingNotional": 0,                                 
  "isCross": true,                                     
  "entryPrice": 0,                                     
  "symbol": "BTCUSD",                                  
  "seqNo": null,                                       
  "sellingNotional": -0.116909,                        
  "riskLimit": 100,                                    
  "totalPnl": 0,                                       
  "feeRateTaker": 0.0007,                              
  "sellingSize": -1400,                                
  "unrealizedPnl": 0,                                  
  "realisedPnl": 0,                                    
  "equity": 0,                                         
  "buyingSize": 0,                                     
  "orderMargin": 0.0013327626,                         
  "leverage": 100,                                     
  "margin": 0,                                         
  "rom": 0                                             
}
```

### Set Risk Limit

##### URL

[https://api.basefex.com/positions/{symbol}/risk-limit](https://api.basefex.com/positions/%7Bsymbol%7D/risk-limit)

##### HTTP Request Method

> PUT

##### Request Parameters

| Parameters | Required             | Type   | Note                                                                                                                                                                |
| ---------- | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     | :white\_check\_mark: | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| notional   | :white\_check\_mark: | number |                                                                                                                                                                     |

##### Request Example URL

<https://api.basefex.com/positions/BTCUSD/risk-limit>

##### Request Body Example

``` js
{
  "notional": 200
}
```

##### Response Example

``` js
{
  "notional": 200, 
  "IMR": 0.015   // initial margin rate
}
```

## <span id="open-api-misc"> Misc </span>

### Get Market Price

##### URL

<https://api.basefex.com/instruments/prices>

##### HTTP Request Method

> GET

##### Request Parameters

No parameter needed.

##### Request Example URL

<https://api.basefex.com/instruments/prices>

##### Response Example

> Note：Unit of `BTCUSD` is USD, unit of other contracts are BTC.

``` js
{
    "BTCUSD": [
    {
      "time": 1562223600000,  // timestamp (milliseconds from 1970-1-1)
      "price": 11290          // contract price (unit: USD)
    },
    {
      "time": 1562222700000,
      "price": 11290
    },
    {
      "time": 1562221800000,
      "price": 11290
    }
  ],
  "ETHXBT": [
    {
      "time": 1562223600000,   // timestamp
      "price": 0.023           // contract price (unit: BTC)
    },
    {
      "time": 1562222700000,
      "price": 0.023
    },
    {
      "time": 1562221800000,
      "price": 0.023
    }
  ],
  "HTXBT": [],
  ...
}
```

### Get OrderBook Snapshot

##### URL

[https://api.basefex.com/depth@{symbol}/snapshot](https://api.basefex.com/depth@%7Bsymbol%7D/snapshot)

##### HTTP Request Method

> GET

##### Request Parameters

| Parameters | Required             | Type   | Note                                                                                                                                                                |
| ---------- | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     | :white\_check\_mark: | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### Request Example URL

<https://api.basefex.com/depth@BTCUSD/snapshot>

##### Response Example

``` js
{
    "to": 90289544,
    "bestPrices": {
        "ask": 11778.5,
        "bid": 11776
    },
    "lastPrice": 11777.0,
    "bids": {
        "11770.5": 783,
        "11776": 1943,
        "6500": 300,
        "11766": 5148
    },
    "asks": {
        "11790": 28285,
        "11778.5": 3333,
        "12350": 1000
    },
    "from": 0
}
```

### Get List of Contracts’ Detail

##### URL

<https://api.basefex.com/instruments>

##### HTTP Request Method

> GET

##### Request Parameters

No parameter needed.

##### Request Example URL

<https://api.basefex.com/instruments>

##### Response Example

``` js
[
  {
    "turnover24h": 2606.3164679306547,    
    "openInterest": 3009639,              
    "volume24hInUsd": 29738395,           
    "fundingRate": 0,                     
    "volume24h": 29738395,                
    "last24hMaxPrice": 12063,             
    "btcPrice": 11767.48,                 
    "latestPrice": 11769.5,               
    "symbol": "BTCUSD",                  // contract type
    "openValue": 255.98924199050046,     
    "last24hMinPrice": 10950.5,              
    "openTime": 0,                       
    "markPrice": 11767.48,               
    "indexPrice": 11767.48               
  },
  {
    "turnover24h": 1042.63566,
    "openInterest": 3919,
    "volume24hInUsd": 12269194.276336798,
    "fundingRate": 0.0001,
    "volume24h": 40270,
    "last24hMaxPrice": 0.02626,
    "btcPrice": 11767.48,
    "latestPrice": 0.02524,
    "symbol": "ETHXBT",                  // contract type
    "openValue": 98.61654386057411,
    "last24hMinPrice": 0.02523,
    "openTime": 0,
    "markPrice": 0.0252588,
    "indexPrice": 0.02525804
  },
```

## WebSocket

## <span id="open-api-ws"> WebSocket Pushing API </span>

### Subscribe Information of Contracts

Get contract details by one of Contract
types.

##### URL

[wss://ws.basefex.com/instruments@{symbol}](wss://ws.basefex.com/instruments@%7Bsymbol%7D)

##### Request Parameters

| Parameters | Required             | Type   | Note                                                                                                                                                                |
| ---------- | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     | :white\_check\_mark: | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### Request Example

> wscat -c <wss://ws.basefex.com/instruments@BTCUSD>

##### Response Example

``` js
[
    {
        "turnover24h": 0.354295837,       
        "openInterest": 3412,             
        "volume24hInUsd": 4000,           
        "fundingRate": 0,                 
        "volume24h": 4000,                
        "last24hMaxPrice": 11290,         
        "btcPrice": 11255.51,             
        "latestPrice": 11290,             
        "symbol": "BTCUSD",               
        "openValue": 0.300825969916003,   
        "last24hMinPrice": 11290,         
        "openTime": 0,                    
        "markPrice": 11255.51,            
        "indexPrice": 11255.51            
    }
]
```

### Subscribe OrderBook

Push snapshot at first, and keep pushing real-time changes
later.

##### URL

[wss://ws.basefex.com/depth@{symbol}](wss://ws.basefex.com/depth@%7Bsymbol%7D)

##### Request Parameters

| Parameters | Required             | Type   | Note                                                                                                                                                                |
| ---------- | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     | :white\_check\_mark: | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### Request Example

> wscat -c <wss://ws.basefex.com/depth@BTCUSD>

##### Response Example

Snapshot

``` js
{
    "to": 91277134,
    "bestPrices": {
        "ask": 11202.5,     
        "bid": 11192.5      
    },
    "lastPrice": 11183.5,
    "bids": {
        "11192": 35,    
        "11184": 742,
        "11192.5": 389,     
        "11188": 293
    },
    "asks": {
        "11202.5": 1806,    
        "11212.5": 2138,
        "11211.5": 19308
    },
    "from": 0
}
```

Real-time

``` js
{
    "bids": {                   
        "11183": 3500
    },
    "lastPrice": 11183.5,
    "from": 91277135,
    "bestPrices": {         
        "ask": 11202.5,
        "bid": 11192.5
    },
    "asks": {},
    "to": 91277135
}
```

### Subscribe Candlesticks

##### URL

[wss://ws.basefex.com/candlesticks/{type}@{symbol}](wss://ws.basefex.com/candlesticks/%7Btype%7D@%7Bsymbol%7D)

##### Request Parameters

| Parameters | Required             | Type   | Note                                                                                                                                                                |
| ---------- | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| type       | :white\_check\_mark: | string | period of time                                                                                                                                                      |
| symbol     | :white\_check\_mark: | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### Request Example

> wscat -c <wss://ws.basefex.com/candlesticks/1MIN@BTCUSD>

##### Response Example

``` js
[
    {
        "symbol": "BTCUSD",           
        "type": "1MIN",               
        "time": 1562301000000,        
        "open": 11119.5,              
        "close": 11109.5,             
        "high": 11123.5,              
        "low": 11109.5,               
        "nTrades": 4,                 
        "volume": 3427,               
        "turnover": 0.30820388075,    
        "version": 91383701,          
        "nextTs": 1562301060000       
    }
]
```

### Subscribe Real-time Trading History

##### URL

[wss://ws.basefex.com/trades@{symbol}](wss://ws.basefex.com/trades@%7Bsymbol%7D)

##### Request Parameters

| Parameters | Required             | Type   | Note                                                                                                                                                                |
| ---------- | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol     | :white\_check\_mark: | string | Contract types, includes `BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### Request Example

> wscat -c <wss://ws.basefex.com/trades@BTCUSD>

##### Response Example

Snapshot

``` js
[
    {
        "id": "5aefeab9-6840-0000-0001-0000056fe3c8", 
        "symbol": "BTCUSD",                           
        "price": 11178.5,                             
        "size": 100,                                  
        "matchedAt": 1562288776609,                   
        "side": "BUY"                                 
    },
    {
        "id": "5aefeb33-e940-0000-0001-0000056fea51",
        "symbol": "BTCUSD",
        "price": 11180,
        "size": 60,
        "matchedAt": 1562288902053,
        "side": "SELL"
    },
    ...
]
```

Real-time

``` js
[
    {
        "id": "5af01b50-9700-0000-0001-000005727d9b",
        "symbol": "BTCUSD",
        "price": 11138,
        "size": 267,
        "matchedAt": 1562301514332,
        "side": "BUY"
    }
]
```
