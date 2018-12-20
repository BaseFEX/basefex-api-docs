# WebSocket Streams for BaseFEX

- [General Information](#general-information)
- [Detailed Stream Information](#detailed-stream-information)
  - [/quotation/candlesticks/{type}@{symbol}](#quotationcandlestickstypesymbol)
  - [/quotation/depth@{symbol}](#quotationdepthsymbol)
  - [/quotation/instruments](#quotationinstruments)
  - [/quotation/instruments@{symbol}](#quotationinstrumentssymbol)
  - [/quotation/trades@{symbol}](#quotationtradessymbol)
  - [/stream](#stream)

## General Information

- The WebSocket base URL is **wss://api.basefex.com/v1**
- BaseFEX API Explorer: **https://www.basefex.com/api/explorer**

## Detailed Stream Information

### /quotation/candlesticks/{type}@{symbol}

The candlesticks stream.

**Parameters**

| Name     | Type   | Mandatory | Description                                             |
|----------|--------|-----------|---------------------------------------------------------|
| `type`   | String | YES       | [ENUM Candlestick Type](./rest-api.md#candlestick-type) |
| `symbol` | String | YES       | [ENUM Symbol](./rest-api.md#symbol)                     |

**Payload**

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

**Example**

`/quotation/candlesticks/1min@BTCUSD`

### /quotation/depth@{symbol}

**Parameters**

| Name     | Type   | Mandatory | Description                         |
|----------|--------|-----------|-------------------------------------|
| `symbol` | String | YES       | [ENUM symbol](./rest-api.md#symbol) |

**Payload**

```js
{
  "asks": {},
  "bids": {},
  "from": 0,
  "to": 0
}
```

**Example**

`/quotation/depth@BTCUSD`

### /quotation/instruments

**Parameters**: N/A

**Payload**

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

### /quotation/instruments@{symbol}

**Parameters**

| Name     | Type   | Mandatory | Description                         |
|----------|--------|-----------|-------------------------------------|
| `symbol` | String | YES       | [ENUM symbol](./rest-api.md#symbol) |

**Payload**

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

**Example**

`/quotation/instruments@BTCUSD`

### /quotation/trades@{symbol}

**Parameters**

| Name     | Type   | Mandatory | Description |
|----------|--------|-----------|-------------|
| `symbol` | String | YES       | ENUM symbol |

**Payload**

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

**Example**

`/quotation/trades@BTCUSD`

### /stream

This interface must add `X-API-KEY`, `X-API-Expires`, `X-API-Signature` HTTP headers to authenticating.

**Payload**

```js
{
  "cash": {
    "available_balance": "0.0",
    "currency": "BTC",
    "id": "00000000-0000-0000-0000-000000000000",
    "margin_balance": "0.0",
    "order_margin": "0.0",
    "position_margin": "0.0",
    "unrealised_pnl": "0.0",
    "wallet_balance": "0.0"
  },
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
    "status": "NEW | PARTIALLY_FILLED | FILLED | CANCELED | PARTIALLY_CANCELED | REJECTED",
    "symbol": "BTCUSD",
    "type": "LIMIT | MARKET | IOC | FOK | POST_ONLY"
  },
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
  "trade": {
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
  },
  "user_id": "00000000-0000-0000-0000-000000000000"
}
```
