# Web Socket Streams for BaseFEX

## General WSS information

- The base endponit is: **wss://api.basefex.com/v1**

## Detailed Stream information

## /quotation/candlesticks/{type}@{symbol}

The candlesticks stream updates data.

Parameters: 

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
type | String | YES | ENUM type
symbol | String | YES | ENUM symbol

Payload:

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

Example:

`/quotation/candlesticks/1min@BTCUSD`

## /quotation/depth@{symbol}

Parameters: 

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | String | YES | ENUM symbol

Payload:

```js
{
  "asks": {},
  "bids": {},
  "from": 0,
  "to": 0
}
```

Example:

`/quotation/depth@BTCUSD`

## /quotation/instruments

Parameters: NONE

Payload:

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

## /quotation/instruments@{symbol}

Parameters: 

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | String | YES | ENUM symbol

Payload:

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

Example:

`/quotation/instruments@BTCUSD`

## /quotation/trades@{symbol}

Parameters: 

Name | Type | Mandatory | Description
------------ | ------------ | ------------ | ------------
symbol | String | YES | ENUM symbol

Payload:

```js
{
  "data": [
    {
      "matched_at": 0,
      "price": 0,
      "side": "BUY | SELL | CANCEL",
      "size": 0,
      "symbol": "BTCUSD"
    }
  ]
}
```

Example:

`/quotation/trades@BTCUSD`
