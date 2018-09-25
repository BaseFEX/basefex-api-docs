# Public Rest API for BaseFEX

## General API information

- The base endpoint is: **https://api.basefex.com/v1**
- All endpoints return a JSON object.
- HTTP 4xx return codes are used for malformed requests, the issue is on the sender's side.
- Any endpoint may return an ERROR payload as follows:

```js
{
    "code": "err_account_login_required",
    "message": "Login is required"
}
```

## Authenticating with an API Key

Authentication is done by sending the following HTTP headers:

- `X-API-Key`

Your public API key. 

- `X-API-Expires`

A UNIX timestamp after which the request is no longer valid. This is to prevent replay attacks.

> UNIX timestamps are in seconds. For example, 2018-09-21T01:56:04+08:00 is 1537466164.

- `X-API-Signature`

A signature of the request you are making. It is calculated as `signature = Base64.encode(SHA256WithRSA(privateKey, sigstr)`.

`SHA256WithRSA` use PKCS1v1.5 padding way, that normally is the default for most languages.

`sigstr = ${API-KEY}${EXPIRES-TIME}${HTTP-METHOD}${PATH-WITH-QUERY-STRING}${HTTP-BODY}`

### SIGNED Endpoint Examples

```
apiKey = "15552edf-dc08-61f0-0000-f0d4e18fccc0"
privateKeyStr = "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAvjN9wBlA8xZP7XkQvUsvGDbBRinq3qe4tQzvGo0yefVwTkri\naZ/Ngd32B9muF62J4LA3v5/oZLyPcKHQgd5sQ27ZdqRE/JUbPE1ZzCJmQ/XV6uiq\nOOIRcencqh2GINvGQTJ8Qe5lzl0liYtKiKPZsYFQjk0dDEbYkoO+osu6HgobXVSe\n/0iDEhx0sqmeDQM7gwBdOrnthGThKSa5kb8bt5w6DUGnyQgvHH/Y01gF3KOp0owy\nyVehuJXJURTcYCX6bg0FF1wM5BnxY6kpG7DzSaMsNdr6taZ2sDR6Ip3jdWsDsFv7\nQvHzGwm5yWic11fREBRSR3zV6cV1W6nQ41jIowIDAQABAoIBAFy+Fs8YgUcG1iph\nIfxrMKeJ62we/FtdRP9jMyOrPbWiLATBFu2R8k8kv9bMGcuJ3vUkd8qEWnjkSL0O\n6fCpV/j5kCf9qXXP7tvUi7ix/VOeB5TnpjjeYss80VBR3RkgkOcxis1LRXD+klMj\nDFDcNEYNXA5HI6bc1LV8b/RJipMiWwQc9J8/NKDY0JMMuaS6zObNqoFRVilIV0zz\nzUjvgeWf6J1J8SY39uecNFtSHh9UO1kj+4Gs5Af1maZuO0rly95+/tICsZO06/Q9\nzrq7ltBUTuc3aRrOpnMjJGn9rnO/2JF3ULmjkO9nU0zfb0efYBdxp2FhPEk4GxwW\nekp624ECgYEA0axlAbfVVXc6pPewwfr1NP7KmnlW4L2hXXkdhIZMSqa8mK2OzNoK\n81F7D0eXXAWslJBb4jJHd1UJnIzQgrlAPjkQ1Z51PUC1vIVSGQalQ1fdvldt5Epv\nq7At3/v21MQbf14q7FUFn1QuoSDUIj+JsAWX7aAvzPa5VbXHQGAhUjECgYEA6Dmz\nRP7/6qofnPENVItm70WLFWe6mTRdzUhRCDWMTRE+XeEi3Jk6+TV56Jm0OAHzDlur\nS3MjeXd/ePeaPxxEHWTunskIG7EN4e3eCmf1BQ3ZTXnip5e5pp2jROea6L2xeRha\nYKqIO6fmMaa7SHObLmmswdA3XB26FpP1rP333xMCgYBOPuB+0KS7PUBUWd7LtSSW\nv1LKbOe//ORgJpeeYiPMZAbTj0lQJzqY7NpYrGXOwItT8b9oXU0QOlrY4i/Z6NoR\nnmgq3/RuhFyN2s71aeZ4iCzHIIdw/1pHHvsvsC6/3eNJF9I62cu8VsUD+mVP1phC\naQP2eKX9/kDRvIF8A6PLsQKBgGiJwPeoSxAaMUz2/mc2scm4ZpnmLgvVlPxaN5AY\neuYegxLDzGu91txkhFJ/Dq+/wOiPv5ahaDC/6HROEfOjB86rpvd3y9ybYYJ5D+Fj\nVttFlrLX0X5cQMiOYfccw5FOA1xd6CFn4xfnxypGwjwlPpAwJgLBdopTH3gWdxu+\n4BxdAoGBALMkkp4+skz88FxsRcgEI9A5jW9aHnDA5vUFAOyUgNMj2VHUM3wu3AWi\nvUf0cMlrgKMMWnC6EXpET9b4es7B4c6LOUvRtehYht7hTMCgEgUSKfsTuz6EzK7H\ntgxPQTvbm5525Tgtt3+hbmeYlFd99CRlwIXQt0BqIyhKR3UBQI2O\n-----END RSA PRIVATE KEY-----\n"

verb = "GET"
expires = 1537466164 # 2018-09-21T01:56:04+08:00
pathWithQuery = "/api/v1/accounts"
data = ""

# Base64(SHA256WithRSA(privateKey, '15552edf-dc08-61f0-0000-f0d4e18fccc01537190686GET/api/v1/accounts'))
# Result is:
# gALqf5Ik2nStG0Ui9+rOoVxCUU//FSC/DyLV98m1/BulxrVGNUHmFmONW5xjpPc412WirxaQubXs6l2XBIu3rNee0180Wc0p3wIMJLpTWsXI633EZWnFfF/5HWl6LWAjIOGDGL1VAmf4+iY9d6n3/zU61FzCLrbqQlGzDNCZyIEWBBctjIjNNlBDhG4l/XMp/EoqUaG664p1M2ASAfBpqKfwRFGm4QjHxxGTFynkHWejraGFcwOiwfJko8jzcQl0E+hQSXseJyA4yEIVgKv26uBP5ZpO8iwqD2hOgXbKx/exhp85UeYifIcGN+yOjWiCYsMsQJBnLL8vxRFWZoekcQ==

signature = Base64.encode(SHA256WithRSA(privateKey, apiKey + expires + verb + pathWithQuery + data))
```

### golang Example

```go
package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/pem"
	"errors"
	"fmt"
)

func main() {
	privateKeyStr := "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAvjN9wBlA8xZP7XkQvUsvGDbBRinq3qe4tQzvGo0yefVwTkri\naZ/Ngd32B9muF62J4LA3v5/oZLyPcKHQgd5sQ27ZdqRE/JUbPE1ZzCJmQ/XV6uiq\nOOIRcencqh2GINvGQTJ8Qe5lzl0liYtKiKPZsYFQjk0dDEbYkoO+osu6HgobXVSe\n/0iDEhx0sqmeDQM7gwBdOrnthGThKSa5kb8bt5w6DUGnyQgvHH/Y01gF3KOp0owy\nyVehuJXJURTcYCX6bg0FF1wM5BnxY6kpG7DzSaMsNdr6taZ2sDR6Ip3jdWsDsFv7\nQvHzGwm5yWic11fREBRSR3zV6cV1W6nQ41jIowIDAQABAoIBAFy+Fs8YgUcG1iph\nIfxrMKeJ62we/FtdRP9jMyOrPbWiLATBFu2R8k8kv9bMGcuJ3vUkd8qEWnjkSL0O\n6fCpV/j5kCf9qXXP7tvUi7ix/VOeB5TnpjjeYss80VBR3RkgkOcxis1LRXD+klMj\nDFDcNEYNXA5HI6bc1LV8b/RJipMiWwQc9J8/NKDY0JMMuaS6zObNqoFRVilIV0zz\nzUjvgeWf6J1J8SY39uecNFtSHh9UO1kj+4Gs5Af1maZuO0rly95+/tICsZO06/Q9\nzrq7ltBUTuc3aRrOpnMjJGn9rnO/2JF3ULmjkO9nU0zfb0efYBdxp2FhPEk4GxwW\nekp624ECgYEA0axlAbfVVXc6pPewwfr1NP7KmnlW4L2hXXkdhIZMSqa8mK2OzNoK\n81F7D0eXXAWslJBb4jJHd1UJnIzQgrlAPjkQ1Z51PUC1vIVSGQalQ1fdvldt5Epv\nq7At3/v21MQbf14q7FUFn1QuoSDUIj+JsAWX7aAvzPa5VbXHQGAhUjECgYEA6Dmz\nRP7/6qofnPENVItm70WLFWe6mTRdzUhRCDWMTRE+XeEi3Jk6+TV56Jm0OAHzDlur\nS3MjeXd/ePeaPxxEHWTunskIG7EN4e3eCmf1BQ3ZTXnip5e5pp2jROea6L2xeRha\nYKqIO6fmMaa7SHObLmmswdA3XB26FpP1rP333xMCgYBOPuB+0KS7PUBUWd7LtSSW\nv1LKbOe//ORgJpeeYiPMZAbTj0lQJzqY7NpYrGXOwItT8b9oXU0QOlrY4i/Z6NoR\nnmgq3/RuhFyN2s71aeZ4iCzHIIdw/1pHHvsvsC6/3eNJF9I62cu8VsUD+mVP1phC\naQP2eKX9/kDRvIF8A6PLsQKBgGiJwPeoSxAaMUz2/mc2scm4ZpnmLgvVlPxaN5AY\neuYegxLDzGu91txkhFJ/Dq+/wOiPv5ahaDC/6HROEfOjB86rpvd3y9ybYYJ5D+Fj\nVttFlrLX0X5cQMiOYfccw5FOA1xd6CFn4xfnxypGwjwlPpAwJgLBdopTH3gWdxu+\n4BxdAoGBALMkkp4+skz88FxsRcgEI9A5jW9aHnDA5vUFAOyUgNMj2VHUM3wu3AWi\nvUf0cMlrgKMMWnC6EXpET9b4es7B4c6LOUvRtehYht7hTMCgEgUSKfsTuz6EzK7H\ntgxPQTvbm5525Tgtt3+hbmeYlFd99CRlwIXQt0BqIyhKR3UBQI2O\n-----END RSA PRIVATE KEY-----\n"
	apiKeyStr := "15552edf-dc08-61f0-0000-f0d4e18fccc0"

	privateKey, _ := ParseRsaPrivateKeyFromPemStr(privateKeyStr)

	sign := createSign(apiKeyStr, "1537466164", "GET", "/api/v1/accounts", "")

	hash := sha256.New()
	hash.Write([]byte(sign))
	digest := hash.Sum(nil)

	signature, err := rsa.SignPKCS1v15(rand.Reader, privateKey, crypto.SHA256, digest)

	r := base64.StdEncoding.EncodeToString(signature)
	println(r)
	if err != nil {
		println(err.Error())
	}
}

func createSign(key, expiresTime, method, pathWithQuery, body string) string {
	return fmt.Sprintf("%s%s%s%s%s", key, expiresTime, method, pathWithQuery, body)
}

func ParseRsaPrivateKeyFromPemStr(privPEM string) (*rsa.PrivateKey, error) {
	block, _ := pem.Decode([]byte(privPEM))
	if block == nil {
		return nil, errors.New("failed to parse PEM block containing the key")
	}

	priv, err := x509.ParsePKCS1PrivateKey(block.Bytes)
	if err != nil {
		return nil, err
	}

	return priv, nil
}
```

## Public API Endpoints

### ENUM definitions

#### Symbol

- `BTCUSD`
- `ETHUSD`

#### Candlestick type

Name | Description
------------ | ------------ 
MIN | minutes
H | hours
DAY | days
WEEK | weeks
MON | months
YEAD | years

- `1MIN`
- `3MIN`
- `5MIN`
- `10MIN`
- `15MIN`
- `30MIN`
- `1H`
- `2H`
- `3H`
- `4H`
- `6H`
- `8H`
- `12H`
- `1DAY`
- `1WEEK`
- `1MON`
- `1YEAR`

#### Side

- `BUY`
- `SELL`

#### Order status

- `NEW`
- `PARTIALLY_FILLED`
- `FILLED`
- `CANCELED`
- `PARTIALLY_CANCELED`
- `REJECTED`

#### Order Type

- `LIMIT`
- `MARKET`
- `IOC`: Immediate or Cancel
- `FOK`: Fill or Kill
- `POST_ONLY`

### GET /accounts

To list accounts.

Parameters: NONE

Response:

```js
{
  "cashes": [
    {
      "available_balance": "0.0",
      "currency": "BTC",
      "id": "00000000-0000-0000-0000-000000000000",
      "margin_balance": "0.0",
      "order_margin": "0.0",
      "position_margin": "0.0",
      "unrealised_pnl": "0.0",
      "wallet_balance": "0.0"
    }
  ],
  "positions": [
    {
      "entry_price": "0.0",
      "id": "00000000-0000-0000-0000-000000000000",
      "leverage": "0.0",
      "liq_indicator": 0,
      "liq_price": "0.0",
      "margin": "0.0",
      "margin_rate": "0.0",
      "market_price": "0.0",
      "notional": "0.0",
      "realized_pnl": "0.0",
      "return_on_margin": 0,
      "size": "0.0",
      "symbol": "BTCUSD",
      "unrealised_pnl": "0.0"
    }
  ]
}
```

### GET /orders

Parameters: 

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
status | Array[String] | NO | Valid Value: `NEW, INFORCE, FILLED, FAILED`
page | INT | YES |
size | INT | NO | Default 100

Example:

`/orders?page=1&size=200`

Response:

```js
{
  "orders": [
    {
      "avg_price": "0.0",
      "created_at": 0,
      "filled": "0.0",
      "filled_notional": "0.0",
      "id": "00000000-0000-0000-0000-000000000000",
      "notional": "0.0",
      "price": "0.0",
      "remaining": "0.0",
      "remaining_notional": "0.0",
      "side": "BUY | SELL | CANCEL",
      "size": "0.0",
      "status": "NEW | INFORCE | FILLED | FAILED",
      "symbol": "BTCUSD",
      "type": "LIMIT | MARKET | IOC | FOK | POST_ONLY"
    }
  ]
}
```

### POST /orders

To place order.

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
price | String | YES |
side | String | YES | Valid Value: `BUY, SELL, CANCEL`
size | String | YES |
symbol | String | YES | Valid Value: `BTCUSD`
type | String | YES |Valid Value: `LIMIT, MARKET, IOC, FOK, POST_ONLY`

Response:

```js
{}
```

### DELETE /orders

To delete orders.

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
ids | Array[String] | YES | array of order id

Response:

```js
{}
```

### GET /orders/{id}

To read order.

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
id | String | YES | order id

Response:

```js
{
  "order": {
    "avg_price": "0.0",
    "created_at": 0,
    "filled": "0.0",
    "filled_notional": "0.0",
    "id": "00000000-0000-0000-0000-000000000000",
    "notional": "0.0",
    "price": "0.0",
    "remaining": "0.0",
    "remaining_notional": "0.0",
    "side": "BUY | SELL | CANCEL",
    "size": "0.0",
    "status": "NEW | INFORCE | FILLED | FAILED",
    "symbol": "BTCUSD",
    "type": "LIMIT | MARKET | IOC | FOK | POST_ONLY"
  }
}
```

### DELETE /orders/{id}

To cancel order.

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
id | String | YES | order id

Example:

`/orders/15555d91-40ee-42c9-0001-0e9280e65263`

Response:

```js
{}
```

### PUT /positions/{id}

To update position.

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
id | String | YES | position id
is_cross | Bool | YES |
leverage | String | YES |
margin | String | YES |

Response:

```js
{
  "position": {
    "entry_price": "0.0",
    "id": "00000000-0000-0000-0000-000000000000",
    "leverage": "0.0",
    "liq_indicator": 0,
    "liq_price": "0.0",
    "margin": "0.0",
    "margin_rate": "0.0",
    "market_price": "0.0",
    "notional": "0.0",
    "realized_pnl": "0.0",
    "return_on_margin": 0,
    "size": "0.0",
    "symbol": "BTCUSD",
    "unrealised_pnl": "0.0"
  },
  "user_id": "00000000-0000-0000-0000-000000000000"
}
```

### DELETE /positions/{id}

To close position.

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
id | String | YES | order id
price | String | | query parameter

Example:

`/positions/15555d91-40ee-42c9-0001-0e9280e65263?price="6600"`

Response:

```js
{}
```

### GET /quotation/candlesticks/{type}@{symbol}/history

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
type | String | YES | ENUM Candlestick type
symbol | String | YES | ENUM Symbol
size | INT | YES | 
since | INT | NO | unix timestamp

Response:

```js
{
  "data": [
    {
      "close": 0,
      "high": 0,
      "low": 0,
      "n_trades": 0,
      "open": 0,
      "symbol": "BTCUSD",
      "time": 0,
      "type": "string",
      "volume": 0
    }
  ]
}
```

### GET /quotation/funding-rates

Parameters: NONE

Response:

```js
{
  "funding_rates": [
    {
      "funding_rate": 0,
      "n_funding_per_day": 0,
      "time": 0
    }
  ]
}
```

### GET /quotation/instruments

To list productions.

Parameters: NONE

Response:

```js
{
  "data": [
    {
      "funding_rate": 0,
      "index_price": 0,
      "mark_price": 0,
      "open_time": 0,
      "open_value": 0,
      "symbol": "BTCUSD",
      "turnover24h": 0,
      "volume24h": 0
    }
  ]
}
```

### GET /quotation/instruments/prices

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
size | INT | NO | 
since | INT | NO | unix timestamp

Example:

`/quotation/instruments/prices?size=100&since=1537401400`

Response:

```js
{
  "data": [
    {
      "prices": [
        {
          "price": 6304,
          "time": 1537421400
        }
      ],
      "symbol": "BTCUSD"
    }
  ]
}
```

### GET /quotation/price-indices

Parameters: NONE

Response:

```js
{
  "price_indices": [
    {
      "spot_index_price": 0,
      "spot_prices": {},
      "time": 0
    }
  ]
}
```

### GET /quotation/volumes

Parameters: NONE

Response:

```js
{
  "data": [
    {
      "type": "1H | 24H | 30DAY",
      "value": 0
    }
  ]
}
```

### GET /trades

To list trades.

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
page | INT | YES |
size | INT | NO | default size is 100

Response:

```js
{
  "trades": [
    {
      "fee": "0.0",
      "fee_rate": "0.0",
      "notional": "0.0",
      "order": {
        "id": "00000000-0000-0000-0000-000000000000",
        "price": "0.0",
        "size": "0.0",
        "type": "LIMIT | MARKET | IOC | FOK | POST_ONLY"
      },
      "price": "0.0",
      "side": "BUY | SELL | CANCEL",
      "size": "0.0",
      "symbol": "BTCUSD",
      "time": 0
    }
  ]
}
```

### GET /trades@{symbol}

To list symbol trades.

Parameters:

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | String | YES | ENUM Symbol
page | INT | YES |
size | INT | NO | default size is 100

Example:

`/trades@BTCUSD?page=1`

Response:

```js
{
  "trades": [
    {
      "fee": "0.0",
      "fee_rate": "0.0",
      "notional": "0.0",
      "order": {
        "id": "00000000-0000-0000-0000-000000000000",
        "price": "0.0",
        "size": "0.0",
        "type": "LIMIT | MARKET | IOC | FOK | POST_ONLY"
      },
      "price": "0.0",
      "side": "BUY | SELL | CANCEL",
      "size": "0.0",
      "symbol": "BTCUSD",
      "time": 0
    }
  ]
}
```
