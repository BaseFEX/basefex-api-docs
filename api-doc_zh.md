
| [English](./api-doc_en.md) | [中文简体](./api-doc_zh.md) |
| -------------------------- | ----------------------- |

# REST API 和 WebSocket

<!-- toc -->

# 概览

  - 认证
      - [API密钥获取及认证](#open-api-authentication)
  - REST API
      - [账户](#open-api-accounts)
      - [订单](#open-api-orders)
      - [交易](#open-api-trades)
      - [持仓](#open-api-positions)
      - [工具及其他](#open-api-misc)
  - WebSocket
      - [Websocket订阅接口](#open-api-ws)

## 网页端Swagger

  - 模拟交易环境: <https://testnet-api.basefex.com/explorer/index.html#/>
  - 正式交易环境: <https://api.basefex.com/explorer/index.html#/>

## <span id="open-api-authentication"> API 密钥获取及认证 </span>

### 生成`API`密钥

从这个地址获取新的密钥 <https://www.basefex.com/account/keys>。获取时需要双重验证，可以使用 Google
Authenticator 或者 Authy。
将生成的密钥及其ID保管好，密钥用于后续计算`签名`。

### 认证

请求的头部必须包含`过期时间`、`密钥ID`和`签名`。使用HmacSHA256算法计算得到`签名`，多数编程语言都有实现这个算法。签名的计算需要`密钥`、`HTTP请求方法`、`请求相对路径`、`过期时间`和`请求数据`，其中请求数据为JSON字符串，如果是GET方法则为空字符串。

##### 请求需要的头部信息

  - `api-expires`: 过期时间，使用 Unix 时间戳。

最小单位为秒，例如 UTC 时间 2019-07-11 07:52:34 对应的时间戳是
1562831554。这个时间戳与服务器端时间进行对比，如果过期，请求将被拒绝。

  - `api-key`: 密钥ID。

  - `api-signature`: 根据本地请求的内容计算出的签名，计算公式为 hex(HMAC\_SHA256(apiSecret,
    http\_method + path + expires + data))。具体请看Python代码示例。

##### 签名计算规则

``` python
apiKey = '5afd4095-f1fb-41d0-0005-1a0048ffe468'            # 密钥ID
apiSecret = 'OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is=' # 密钥

http_method = 'GET'
path = '/accounts'
expires = 1563148118 # unix时间戳 表示时间 2019-07-14 23:28:38 （UTC零时区）
data = ''

# HEX(HMAC_SHA256(apiSecret, 'GET/accounts1563148118'))
# 计算出的签名是：
# '8b22cc3707d740c8fd43d97d39a52ad1bff3fc35e247fd4baac5e00824192c0c'
signature = HEX(HMAC_SHA256(apiSecret, http_method + path + str(expires) + data))
```

或者使用[这个网站](https://www.freeformatter.com/hmac-generator.html)验证算法的正确性。

##### Python计算签名示例

``` python
from datetime import datetime
import hashlib
import hmac
from urllib.parse import urlparse
import json

# 先哈希 HMAC_SHA256(secret, http_method + path + expires + data)，然后将哈希后的数据转化为16进制字符串即为signature
# http_method是HTTP方法，必须为英文大写；path为相对路径；expires为Unix时间戳，单位为秒。
# data为json字符串
def generate_signature(secret, http_method, url, expires, data):
    # 解析url获取相对路径
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

# 密钥
secret = "OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is="
expires = 1563148118
# 或者从当前时间之后的一段时间有效
# 下边的时间戳5秒之后失效
# timestamp = datetime.now().timestamp()
# expires = int(round(timestamp) + 5)

print(generate_signature(secret, 'GET', '/accounts', expires, ''))
```

#### 接口调用示例

GET请求

``` python
key_id = '5afd4095-f1fb-41d0-0005-1a0048ffe468'         # 替换成你的密钥ID
secret = 'OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is=' # 替换成你的密钥
path = '/accounts'                                      # 相对路径
url = 'https://api.basefex.com' + path
timestamp = datetime.now().timestamp()
expires = int(round(timestamp) + 5)                     # 5秒后失效
data = ''                                               # GET请求，请求体为空字符串
auth_token = generate_signature(secret, "GET", path, expires, data)  
hed = {'api-expires':str(expires),'api-key':key_id,'api-signature':str(auth_token)}
response = requests.get(url, headers=hed)
print(response.json())
```

GET请求（带路径参数）

``` python
key_id = '5afd4095-f1fb-41d0-0005-1a0048ffe468'         # 替换成你的密钥ID
secret = 'OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is=' # 替换成你的密钥
path = '/orders?symbol=BTCUSD'                          # 相对路径
url = 'https://api.basefex.com' + path
timestamp = datetime.now().timestamp()
expires = int(round(timestamp) + 5)                     # 5秒后失效
data = ''                                               # GET请求，请求体为空字符串
auth_token = generate_signature(secret, "GET", path, expires, data)  
hed = {'api-expires':str(expires),'api-key':key_id,'api-signature':str(auth_token)}
response = requests.get(url, headers=hed)
print(response.json())
```

POST请求

``` python
key_id = '5afd0a44-4b68-4e4a-0005-10c406964844'         # 替换成你的密钥ID
secret = "3gA/QTBW3F35pl/oaeONMCA3Wnh9MDrq9728/HyPDu8=" # 替换成你的密钥 
path = '/orders'                                         # 相对路径
url = 'https://api.basefex.com' + path
timestamp = datetime.now().timestamp()
expires = int(round(timestamp) + 5)                     # 5秒后失效
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
response = requests.post(url, headers=hed, json=data)  # post方法，使用headers和json参数
print(response.json())
```

Websocket

``` python
import websockets
auth_token = generate_signature(secret, "GET", "/stream", expires, '') # Http method和请求头部的相同，一般默认为GET
hed = {'api-expires':str(expires),'api-key':key_id,'api-signature':str(auth_token)}
async def hello():
    uri = "wss://api.basefex.com/stream"
    async with websockets.connect(uri, extra_headers=hed) as websocket:
        await websocket.send('{"ping":1573552318023}')
        greeting = await websocket.recv()
        print(f"< {greeting}")

asyncio.get_event_loop().run_until_complete(hello())
```

##### 接口速率限制

所有`REST`接口一分钟内限制`180`次，`WebSockets`订阅一分钟内限制`60`次。每一次返回的`headers`中包含

``` js
x-ratelimit-limit      # 接口限制数
x-ratelimit-remaining  # 剩余调用数
x-ratelimit-reset      # 下一次被允许时间戳（如果超限）
```

请使用批量接口如批量下单，批量撤单等来优化接口调用频率。

## REST API

## <span id="open-api-accounts"> 账户 Accounts </span>

### 获取账户余额和持仓详情

##### URL

<https://api.basefex.com/accounts>

##### HTTP请求方式

> GET

##### 请求参数

无

##### 请求示例URL

<https://api.basefex.com/accounts>

##### 返回示例

``` js
[
    {
      "cash": {                                            // 结算方式
        "orderMargin": 0.0983953764,                       // 委托保证金
        "balances": 1000,                                  // 余额
        "marginRate": 0,                                   // 保证金比率
        "userId": "5aec525e-335d-4724-0005-20153b361f89",  // 
        "leverage": 0,                                     // 杠杆倍数
        "marginBalances": 1000,                            // 保证金余额
        "positionMargin": 0,                               // 仓位保证金
        "available": 999.9016046236,                       // 可用余额
        "unrealizedPnl": 0,                                // 未实现盈亏
        "id": "5aec8f3b-ea46-4eaa-0005-639ddae22e5f",      // 
        "currency": "BTC",                                 // 货币类型BTC
        "margin": 0                                        // 保证金
      },
      "positions": {
        "ETHXBT": {                                          // 合约类型
          "markPrice": 0.02608751,                           // 标记价格
          "value": 0,                                        // 
          "size": 0,                                         // 合约数量
          "liquidatePrice": 0,                               // 
          "risk": 0,                                         // 风险程度
          "symbol": "ETHXBT",                                // 合约类型
          "notional": 0,                                     // 仓位价值
          "userId": "5aec525e-335d-4724-0005-20153b361f89",  // 
          "buyingNotional": 0,                               // 买入总价值
          "isCross": true,                                   // 是否满仓
          "feeRateMaker": 0,                                 // maker费率
          "entryPrice": 0,                                   // 入场价格
          "sellingNotional": 0,                              // 卖出总价值
          "marginRate": 0.02,                                // 保证金比率
          "id": "5aec8f3f-ad95-43a7-0005-c80b43cdb509",      // 
          "seqNo": null,                                     // 
          "leverage": 50,                                    // 杠杆倍数
          "totalPnl": 0,                                     // 总盈亏
          "unrealizedPnl": 0,                                // 未实现盈亏
          "feeRateTaker": 0.002,                             // 
          "orderMargin": 0,                                  // 
          "sellingSize": 0,                                  // 买入合约数量
          "realisedPnl": 0,                                  // 已实现盈亏
          "equity": 0,                                       // 
          "buyingSize": 0,                                   // 买入数量
          "riskLimit": 50,                                   // 风险限额
          "margin": 0,                                       // 保证金
          "rom": 0                                           // 回报率
        },
        ...                                                  // 其他合约
      }
    },
    {
        "cash": {                                          // 
          "currency": "USDT",                              // 货币类型USDT
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
        "positions": []                                    // 仓位
    } 
]
```

<!-- 
### 获取账户权益

##### URL

https://api.basefex.com/accounts/equity

##### HTTP请求方式

> GET

##### 请求参数

无

##### 请求示例URL

https://api.basefex.com/accounts/equity

##### 返回示例

```js
{
  "equity": {
    "available": 0.0000810079987298,  // 可用余额，单位BTC
    "positionMargin": 0,              // 仓位保证金
    "marginBalances": 6.5360025e-9,   // 保证金余额
    "marginBalancesBtc": 6.5360025e-9,// 保证金余额，单位BTC
    "unrealizedPnl": 0                // 为实现盈亏
  }
}
``` -->

### 获取充值和提现记录

##### URL

<https://api.basefex.com/accounts/transactions>

##### HTTP请求方式

> GET

##### 请求参数

| 参数    | 必选 | 类型     | 说明                              |
| ----- | -- | ------ | ------------------------------- |
| type  |    | string | 交易类型，包括充值`DEPOSIT`和提现`WITHDRAW` |
| id    |    | string | 前一次请求中最后一个订单的id，用于分页            |
| limit |    | number | 单次请求结果数目限制，不传值则为100             |

##### 请求示例URL

<https://api.basefex.com/accounts/transactions?type=DEPOSIT&limit=30>

##### 返回示例

``` js
[
  {
    "address": "2N2BUEAqDH1mhYe2tVy1tRPda9jY4KniyjB",                                  // 充值地址
    "foreignTxId": "a862ade7c3a642968b1f1e1412701fd3c854397fa2706b57a9ce1838d3bfddf7", // 外部交易id
    "userId": "5aec525e-335d-4724-0005-20153b361f89",                                  // 
    "status": "NEW",                                                                   // 状态（ NEW,AUDITED,PENDING,COMPLETED,CANCELED,REJECTED ）
    "id": "5aeeeba7-2843-f607-0005-2fdaac7eda8f",                                      // 
    "subtype": null,                                                                   // 
    "amount": 0.0653564,                                                               // 充值或者提现金额
    "balances": null,                                                                  // 
    "ts": 1562221911201,                                                               // 时间
    "type": "DEPOSIT",                                                                 // 充值（或者提现）
    "readableId": null,                                                                // 
    "audit": null,                                                                     // 
    "fee": 0,                                                                          // 费用
    "note": null,                                                                      // 
    "currency": "BTC"                                                                  // 结算类型
  }
]
```

### 获取充值及提现记录数量

##### URL

<https://api.basefex.com/accounts/transactions/count>

##### HTTP请求方式

> GET

##### 请求参数

| 参数   | 必选 | 类型     | 说明                              |
| ---- | -- | ------ | ------------------------------- |
| type |    | string | 交易类型，包括充值`DEPOSIT`和提现`WITHDRAW` |

##### 请求示例URL

<https://api.basefex.com/accounts/transactions/count?type=DEPOSIT>

##### 返回示例

``` js
{
  "count": 1
}
```

## <span id="open-api-orders"> 订单 Orders </span>

<!-- GET /orders/{id} -->

<!-- Done -->

### 获取单个订单

通过订单id获取订单详情。

##### URL

[https://api.basefex.com/orders/{id}](https://api.basefex.com/orders/%7Bid%7D)

##### HTTP请求方式

> GET

##### 请求参数

| 参数 | 必选                   | 类型     | 说明   |
| -- | -------------------- | ------ | ---- |
| id | :white\_check\_mark: | string | 订单id |

##### URL请求示例

<https://api.basefex.com/orders/5aec8f9f-1609-4e54-0005-86e30e0cb1c6>

##### 返回示例

``` js
{
  "liquidateUserId": null,
  "side": "BUY",                                    // 买卖方向
  "meta": {                                         // 
    "bestPrice": null,                              // 
    "markPrice": 10051.43,                          // 
    "bestPrices": {                                 // 
      "ask": null,                                  // 
      "bid": null                                   // 
    }                                               // 
  },                                                // 
  "userId": "5aec525e-335d-4724-0005-20153b361f89", // 
  "filledNotional": 0,                              // 已成交部分的价值
  "ts": 1562063567960,                              // 
  "notional": 0.102512,                             // 订单价值
  "status": "NEW",                                  // 订单状态
  "isLiquidate": false,                             // 是否强平
  "reduceOnly": false,                              // 是否只减仓
  "type": "LIMIT",                                  // 订单类型
  "symbol": "BTCUSD",                               // 合约类型
  "seqNo": null,                                    // 
  "filled": 0,                                      // 成交数量
  "conditional": null,                              // 
  "id": "5aec8f9f-1609-4e54-0005-86e30e0cb1c6",     // 
  "size": 1000,                                     // 订单大小（合约数量）
  "avgPrice": 0,                                    // 
  "price": 9755                                     // 订单价格
}                                                     
```

<!-- POST /orders -->

<!-- Done -->

### 提交单个订单

##### URL

<https://api.basefex.com/orders>

##### HTTP请求方式

> POST

##### 请求参数

| 参数          | 必选                   | 类型      | 说明                                                                                                                                                |
| ----------- | -------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| size        | :white\_check\_mark: | number  | 合约数量                                                                                                                                              |
| symbol      | :white\_check\_mark: | string  | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| type        | :white\_check\_mark: | string  | 订单类型，可选值：`LIMIT`, `MARKET`, `IOC`, `FOK`, `POST_ONLY`                                                                                             |
| side        | :white\_check\_mark: | string  | 买入`BUY`或者卖出`SELL`                                                                                                                                 |
| price       |                      | number  | 订单价格                                                                                                                                              |
| reduceOnly  |                      | boolean | 如果为true，则只减少持仓而不会增加持仓，即如果这个订单将要增加仓位时，这个订单将会被自动取消。                                                                                                 |
| conditional |                      | object  | 可通过 conditional 是否为 null 来判断是否为条件委托，conditional的type目前只有 `REACH`，priceType 包括 `MARK_PRICE`、`INDEX_PRICE`、`MARKET_PRICE`                           |

##### URL请求示例

<https://api.basefex.com/orders>

##### 请求体示例

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

##### 返回示例

``` js
{
  "meta": null,                                     // 
  "reduceOnly": false,                              // 是否只支持平仓
  "symbol": "BTCUSD",                               // 合约类型
  "type": "LIMIT",                                  // 订单类型
  "userId": "5aec525e-335d-4724-0005-20153b361f89", // 
  "liquidateUserId": null,                          // 
  "size": 1,                                        // 订单大小（合约数量）
  "notional": 0,                                    // 订单价值
  "status": "UNTRIGGERED",                          // 订单状态
  "id": "5aed7b45-5d19-40f2-0005-ca49d01f33e3",     // 
  "side": "BUY",                                    // 买卖方向
  "filledNotional": 0,                              // 已成交价值
  "seqNo": null,                                    // 
  "filled": 0,                                      // 成交数量
  "price": 8000,                                    // 订单价格
  "conditional": {                                  // 
    "type": "REACH",                                // 条件
    "priceType": "MARKET_PRICE",                    // 使用哪种价格
    "price": 8000                                   // 触发条件价格
  }
}
```

<!-- DELETE /orders/{id} -->

<!-- Done -->

### 撤销单个订单

通过订单id撤销这个订单

##### URL

[https://api.basefex.com/orders/{id}](https://api.basefex.com/orders/%7Bid%7D)

##### HTTP请求方式

> DELETE

##### 请求参数

| 参数 | 必选                   | 类型     | 说明   |
| -- | -------------------- | ------ | ---- |
| id | :white\_check\_mark: | string | 订单id |

##### 请求URL示例

<https://api.basefex.com/orders/5aec8f9f-1609-4e54-0005-86e30e0cb1c6>

无返回内容

<!-- GET /orders -->

<!-- Done -->

### 获取订单列表（分页）

使用限定参数(可选)获取订单列表

##### URL

<https://api.basefex.com/orders>

##### HTTP请求方式

> GET

##### 请求参数

| 参数     | 必选 | 类型     | 说明                                                                                                                                                |
| ------ | -- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol |    | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id     |    | string | 前一次请求中最后一个订单的id，用于分页                                                                                                                              |
| type   |    | string | `LIMIT` `MARKET` `IOC` `FOK` `POST_ONLY`                                                                                                          |
| side   |    | string | 买入`BUY`或者卖出`SELL`                                                                                                                                 |
| status |    | string | 订单状态，包括`NEW`, `PARTIALLY_FILLED`, `PARTIALLY_CANCELED`, `CANCELED`, `REJECTED`, `FILLED`, `UNTRIGGERED`, `PENDING_CANCEL`, `TRIGGERED`            |
| opt    |    | string | 已触发`TRIGGERED` 或者强平`LIQUIDATE`                                                                                                                    |
| limit  |    | number | 单次请求结果数目限制                                                                                                                                        |

无参数限定时返回所有订单。

##### 请求URL示例

<https://api.basefex.com/orders?symbol=BTCUSD&type=LIMIT&side=BUY&status=NEW&limit=30>

##### 返回示例

``` js
[
  {
    "liquidateUserId": null,                          // 
    "id": "5aed94fc-703e-42a2-0005-578d4c468767",     // 
    "ts": 1562132083136,                              // 时间戳
    "side": "BUY",                                    // 买卖方向
    "userId": "5aec525e-335d-4724-0005-20153b361f89", // 
    "filledNotional": 0,                              // 已成交价值
    "notional": 0.102512,                             // 订单价值
    "status": "NEW",                                  // 订单状态
    "isLiquidate": false,                             // 是否强平
    "reduceOnly": false,                              // 是否只支持减仓
    "type": "LIMIT",                                  // 订单类型
    "symbol": "BTCUSD",                               // 合约类型
    "seqNo": null,                                    // 
    "filled": 0,                                      // 已成交数量
    "conditional": null,                              // 
    "size": 1000,                                     // 
    "avgPrice": 0,                                    // 
    "price": 9755,                                    // 订单价格
    "meta": {                                         // 
      "bestPrice": 11311,                             // 
      "markPrice": 11536.1075491,                     // 
      "bestPrices": {                                 // 
        "ask": 11311,                                 // 
        "bid": 11305.5                                // 
      }
    }
  }
]
```

<!-- POST /orders/batch -->

### 批量提交订单

##### URL

<https://api.basefex.com/orders/batch>

##### HTTP请求方式

> POST

##### 请求参数

| 参数     | 必选                   | 类型     | 说明                                                                                                                                                |
| ------ | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol | :white\_check\_mark: | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| orders | :white\_check\_mark: | list   | price为合约单价，类型为number；size为合约数量，类型为number；side为买卖方向，`BUY`或者`SELL`，类型为string                                                                        |

##### 请求示例URL

<https://api.basefex.com/orders/batch>

##### 请求体示例

``` js
{
  "symbol": "BTCUSD",
  "orders": [
    {
      "price": 11234,
      "size": 200,
      "side": "BUY"
    }
  ]
}
```

##### 返回示例

``` js
[
  {
    "liquidateUserId": null,                           // 
    "price": 11234,                                    // 价格
    "size": 200,                                       // 合约数量
    "id": "5aedb78e-6641-4d00-0005-2b2439f84663",      // 
    "userId": "5aec525e-335d-4724-0005-20153b361f89",  // 
    "filledNotional": 0,                               // 已成交价值
    "ts": 1562141145497,                               // 订单提交时间
    "status": "NEW",                                   // 订单状态
    "isLiquidate": false,                              // 是否强平
    "reduceOnly": false,                               // 是否只支持减仓
    "type": "LIMIT",                                   // 订单种类
    "symbol": "BTCUSD",                                // 合约类型
    "seqNo": null,                                     // 
    "filled": 0,                                       // 已成交数量
    "conditional": null,                               // 委托条件
    "side": "BUY",                                     // 买卖方向
    "avgPrice": 0,                                     // 
    "meta": {                                          // 
      "markPrice": 11303.14,                           // 标记价格
      "bestPrices": {                                  // 
        "ask": 11311,                                  // 卖盘最低价
        "bid": 11305.5                                 // 买盘最高价
      },                                               // 
      "bestPrice": 11305.5                             // 
    },                                                 // 
    "notional": 0.017804                               // 订单价值
  }                                                    
]
```

<!-- DELETE /orders -->

<!-- Deprecate -->

<!-- ### 批量撤销订单

##### URL

https://api.basefex.com/orders

##### HTTP请求方式

> DELETE

https://api.basefex.com/orders?symbol=BTCUSD&side=BUY

##### 请求参数

| 参数   | 必选 | 类型   | 说明                                   |
|--------|------|--------|----------------------------------------|
| symbol |      | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| side   |      | string | `BUY` `SELL`                           |

无返回内容 -->

### 批量撤销订单

##### URL

<https://api.basefex.com/orders/batch>

##### HTTP请求方式

> DELETE

##### 请求参数

| 参数     | 必选                   | 类型     | 说明                                                                                                                                                |
| ------ | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol | :white\_check\_mark: | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| ids    |                      | list   | 订单id列表                                                                                                                                            |

##### 请求示例URL

<https://api.basefex.com/orders/batch>

##### 请求体示例

``` js
{
  "symbol": "BTCUSD",
  "ids": [
    "5aedb78e-6641-4d00-0005-2b2439f84663",
    "5aed7b45-5d19-40f2-0005-ca49d01f33e3"
  ]
}
```

无返回内容

<!-- GET /orders/opening -->

<!-- Done -->

### 获取活跃订单

##### URL

<https://api.basefex.com/orders/opening>

##### HTTP请求方式

> GET

##### 请求参数

| 参数     | 必选 | 类型     | 说明                                                                                                                                                |
| ------ | -- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol |    | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id     |    | string | 前一次请求中最后一个订单的id，用于分页                                                                                                                              |
| limit  |    | number | 单次请求的结果数目限制，不传值则为100                                                                                                                              |

##### URL请求示例

<https://api.basefex.com/orders/opening?symbol=BTCUSD&limit=30>

##### 返回示例

``` js
[
  {
    "liquidateUserId": null,                          // 
    "ts": 1562125342068,                              // 
    "size": 1,                                        // 
    "notional": 0,                                    // 订单价值
    "side": "BUY",                                    // 买卖方向
    "userId": "5aec525e-335d-4724-0005-20153b361f89", // 
    "filledNotional": 0,                              // 已成交价值
    "isLiquidate": false,                             // 是否强平
    "reduceOnly": false,                              // 是否只支持减仓
    "type": "LIMIT",                                  // 订单类型
    "symbol": "BTCUSD",                               // 合约类型
    "seqNo": null,                                    // 
    "filled": 0,                                      // 成交数量
    "meta": null,                                     // 
    "status": "UNTRIGGERED",                          // 订单状态
    "avgPrice": 0,                                    // 
    "price": 8000,                                    // 
    "conditional": {                                  // 委托条件
      "type": "REACH",                                // 委托类型
      "price": 8000,                                  // 委托价格
      "priceType": "MARKET_PRICE"                     // 使用哪种价格
    },                                                // 
    "id": "5aed7b45-5d19-40f2-0005-ca49d01f33e3"      // 
  }                                                     
]                                                     
```

<!-- GET /orders/count -->

<!-- Done -->

### 获取订单数目

##### URL

<https://api.basefex.com/orders/count>

##### HTTP请求方式

> GET

##### 请求参数

| 参数     | 必选 | 类型     | 说明                                                                                                                                                |
| ------ | -- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol |    | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id     |    | string | 前一次请求中最后一个订单的id，用于分页                                                                                                                              |
| type   |    | string | `LIMIT` `MARKET` `IOC` `FOK` `POST_ONLY`                                                                                                          |
| side   |    | string | 买入`BUY`或者卖出`SELL`                                                                                                                                 |
| status |    | string | 订单状态，包括`NEW`, `PARTIALLY_FILLED`, `PARTIALLY_CANCELED`, `CANCELED`, `REJECTED`, `FILLED`, `UNTRIGGERED`, `PENDING_CANCEL`, `TRIGGERED`            |
| opt    |    | string | `TRIGGERED` `LIQUIDATE`                                                                                                                           |

##### 请求示例URL

<https://api.basefex.com/orders/count?symbol=BTCUSD&type=LIMIT&side=BUY&status=NEW>

##### 返回示例

``` js
{
  "count": 1             // 数量
}
```

<!-- GET /orders/opening/count -->

<!-- Done -->

### 获取活跃订单数目

##### URL

<https://api.basefex.com/orders/opening/count>

##### HTTP请求方式

> GET

##### 请求参数

| 参数     | 必选 | 类型     | 说明                                                                                                                                                |
| ------ | -- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol |    | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### 请求示例URL

<https://api.basefex.com/orders/opening/count?symbol=BTCUSD>

##### 返回示例

``` js
{
  "count": 2                 // 数量
}
```

## <span id="open-api-trades"> 交易 Trades </span>

### 获取交易列表

##### URL

<https://api.basefex.com/trades>

##### HTTP请求方式

> GET

##### 请求参数

| 参数       | 必选 | 类型     | 说明                                                                                                                                                |
| -------- | -- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol   |    | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id       |    | string | 前一次请求中最后一个订单的id，用于分页                                                                                                                              |
| limit    |    | number | 单次请求结果数目限制，不传值则为10                                                                                                                                |
| side     |    | string | 买入`BUY`，卖出`SELL`，或者平台每8个小时触发的`FUNDING`                                                                                                            |
| order-id |    | string | 订单id                                                                                                                                              |

##### 请求示例URL

<https://api.basefex.com/trades?limit=30&side=SELL>

##### 返回示例

``` js
[
  {
    "fee": 0.00006200177148,                           // 手续费
    "symbol": "BTCUSD",                                // 合约类型
    "feeRate": 0.0007,                                 // 费率
    "size": 1000,                                      // 合约数量
    "ts": 1562244089804,                               // 成交时间
    "notional": 0.08857395925,                         // 成交价值
    "orderId": "5aef4041-ee43-4a60-0005-705a0f1edcb4", // 订单id
    "id": "5aef4041-f300-0000-0001-00000000001b",      // 交易id
    "side": "SELL",                                    // 卖出（还是买入）
    "order": {                                         // 
      "id": "5aef4041-ee43-4a60-0005-705a0f1edcb4",    // 订单id
      "type": "LIMIT",                                 // 订单类型
      "size": 1000,                                    //
      "price": 11290                                   // 
    },
    "price": 11290
  }
]
```

### 获取交易数量

##### URL

<https://api.basefex.com/trades/count>

##### HTTP请求方式

> GET

##### 请求参数

| 参数       | 必选 | 类型     | 说明                                                                                                                                                |
| -------- | -- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol   |    | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| id       |    | string | 前一次请求中最后一个订单的id，用于分页                                                                                                                              |
| limit    |    | number | 单次请求结果数目限制，不传值则为10                                                                                                                                |
| side     |    | string | 买入`BUY`，卖出`SELL`，或者平台每8个小时触发的`FUNDING`                                                                                                            |
| order-id |    | string | 订单id                                                                                                                                              |

##### 请求示例URL

<https://api.basefex.com/trades/count?symbol=BTCUSD&limit=30&side=BUY>

##### 返回示例

``` js
{
  "count": 3       // 数量
}
```

## <span id="open-api-positions"> 持仓 Positions </span>

### 杠杆调节

##### URL

[https://api.basefex.com/positions/{symbol}/margin](https://api.basefex.com/positions/%7Bsymbol%7D/margin)

##### HTTP请求方式

> PUT

##### 请求参数

| 参数       | 必选                   | 类型      | 说明                                                                                                                                                |
| -------- | -------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol   | :white\_check\_mark: | string  | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| margin   |                      | number  |                                                                                                                                                   |
| leverage |                      | number  | 杠杆倍数，isCross为false时生效。                                                                                                                            |
| isCross  |                      | boolean | true为全仓，false时leverage字段生效                                                                                                                        |

##### 请求示例URL

<https://api.basefex.com/positions/BTCUSD/margin>

##### 请求体示例

``` js
{
  "margin": 0,
  "leverage": 0,
  "isCross": true
}
```

##### 返回示例

``` js
{
  "feeRateMaker": -0.0002,                             // maker费率
  "id": "5aec8f3f-9846-41af-0005-1b306eeb533a",        // 
  "value": 0,                                          // 仓位价值
  "marginRate": 0.01,                                  // 保证金比率
  "size": 0,                                           // 
  "liquidatePrice": 0,                                 // 强平价格
  "markPrice": 11303.14,                               // 标记价格
  "risk": 0,                                           // 风险程度                                         
  "notional": 0,                                       // 仓位名义价值
  "userId": "5aec525e-335d-4724-0005-20153b361f89",    // 用户ID   
  "buyingNotional": 0,                                 // 
  "isCross": true,                                     // 是否全仓      
  "entryPrice": 0,                                     // 入场价格
  "symbol": "BTCUSD",                                  // 合约类型
  "seqNo": null,                                       // 
  "sellingNotional": -0.116909,                        // 
  "riskLimit": 100,                                    // 风险限额
  "totalPnl": 0,                                       // 总盈亏
  "feeRateTaker": 0.0007,                              // taker费率
  "sellingSize": -1400,                                // 卖出数量
  "unrealizedPnl": 0,                                  // 未实现盈亏
  "realisedPnl": 0,                                    // 已实现盈亏
  "equity": 0,                                         // 
  "buyingSize": 0,                                     // 
  "orderMargin": 0.0013327626,                         // 订单保证金
  "leverage": 100,                                     // 杠杆
  "margin": 0,                                         // 保证金
  "rom": 0                                             // 回报率
}
```

### 设置风险限额

##### URL

[https://api.basefex.com/positions/{symbol}/risk-limit](https://api.basefex.com/positions/%7Bsymbol%7D/risk-limit)

##### HTTP请求方式

> PUT

##### 请求参数

| 参数       | 必选                   | 类型     | 说明                                                                                                                                                |
| -------- | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol   | :white\_check\_mark: | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |
| notional | :white\_check\_mark: | number |                                                                                                                                                   |

##### 请求示例URL

<https://api.basefex.com/positions/BTCUSD/risk-limit>

##### 请求体示例

``` js
{
  "notional": 200
}
```

##### 返回示例

``` js
{
  "notional": 200, 
  "IMR": 0.015   // initial margin rate，初始保证金比率
}
```

## <span id="open-api-misc"> 其他 Misc </span>

### 获取合约价格

获取平台所有合约的价格

##### URL

<https://api.basefex.com/instruments/prices>

##### HTTP请求方式

> GET

##### 请求参数

无

##### 请求示例URL

<https://api.basefex.com/instruments/prices>

##### 返回示例

> 说明：目前价格单位只有`BTCUSD`为美元，其他合约为比特币。

``` js
{
    "BTCUSD": [
    {
      "time": 1562223600000,  // 时间戳（距离1970年1月1日的毫秒数）
      "price": 11290          // 合约价格（单位：美元）
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
      "time": 1562223600000,   // 时间戳
      "price": 0.023           // 价格 （单位：BTC）
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

### 获取合约24小时涨跌幅

获取平台所有合约的24小时内价格的涨跌幅

##### URL

<https://api.basefex.com/instruments/difference>

##### HTTP请求方式

> GET

##### 请求参数

无

##### 请求示例URL

<https://api.basefex.com/instruments/difference>

##### 返回示例

``` js
{
  "BTCUSD": -0.009252547648488466,
  "ETHXBT":  0.008724589346875234,
  "XRPXBT": "No Data",              // 无输入数据
  "BCHXBT": "No Data",
  "LTCXBT": "No Data",
  "BNBXBT": "No Data",
  "BTCUSDT": "No Data"
}
```

### 获取买卖盘实时行情

##### URL

[https://api.basefex.com/depth@{symbol}/snapshot](https://api.basefex.com/depth@%7Bsymbol%7D/snapshot)

##### HTTP请求方式

> GET

##### 请求参数

| 参数     | 必选                   | 类型     | 说明                                                                                                                                                |
| ------ | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol | :white\_check\_mark: | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### 请求示例URL

<https://api.basefex.com/depth@BTCUSD/snapshot>

##### 返回示例

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

### 获取合约详情列表

##### URL

<https://api.basefex.com/instruments>

##### HTTP请求方式

> GET

##### 请求参数

无

##### 请求示例URL

<https://api.basefex.com/instruments>

##### 返回示例

``` js
[
  {
    "turnover24h": 2606.3164679306547,    // 前24小时交易额（单位BTC）
    "openInterest": 3009639,              // 未平仓合约数量
    "volume24hInUsd": 29738395,           // 24小时交易量（美元计）
    "fundingRate": 0,                     // 资金费率
    "volume24h": 29738395,                // 24小时交易量
    "last24hMaxPrice": 12063,             // 24小时内最大成交价
    "btcPrice": 11767.48,                 // 现货价格（美元计）
    "latestPrice": 11769.5,               // 最新成交价
    "symbol": "BTCUSD",                  // 合约类型
    "last24hPriceChange": -0.07677342823250297, //前24小时涨跌幅
    "openValue": 255.98924199050046,     // 未平仓合约总价值（BTC计）
    "last24hMinPrice": 10950.5,          // 前24小时最低价
    "openTime": 0,                       // 
    "markPrice": 11767.48,               // 标记价格
    "indexPrice": 11767.48               // 指数价格
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
    "symbol": "ETHXBT",                  // 合约类型
    "last24hPriceChange": -0.0537359263050153,
    "openValue": 98.61654386057411,
    "last24hMinPrice": 0.02523,
    "openTime": 0,
    "markPrice": 0.0252588,
    "indexPrice": 0.02525804
  },
```

## WebSocket

## <span id="open-api-ws"> WebSocket 推送接口 </span>

### 订阅市场行情

订阅某个合约的实时详情

##### URL

[wss://ws.basefex.com/instruments@{symbol}](wss://ws.basefex.com/instruments@%7Bsymbol%7D)

##### 请求参数

| 参数     | 必选                   | 类型     | 说明                                                                                                                                                |
| ------ | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol | :white\_check\_mark: | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### 请求示例（使用wscat）

> wscat -c <wss://ws.basefex.com/instruments@BTCUSD>

##### 返回示例

``` js
[
    {
        "turnover24h": 0.354295837,       // 24小时交易额（单位BTC）
        "openInterest": 3412,             // 未平仓合约数量
        "volume24hInUsd": 4000,           // 24小时交易量（美元计）
        "fundingRate": 0,                 // 资金费率
        "volume24h": 4000,                // 24小时交易量
        "last24hMaxPrice": 11290,         // 24小时内最大成交价
        "btcPrice": 11255.51,             // 现货价格（美元计）
        "latestPrice": 11290,             // 最新成交价
        "symbol": "BTCUSD",               // 合约类型
        "openValue": 0.300825969916003,   // 未平仓合约总价值（BTC计）
        "last24hMinPrice": 11290,         // 前24小时最低价
        "openTime": 0,                    // 
        "markPrice": 11255.51,            // 标记价格
        "indexPrice": 11255.51            // 指数价格
    }
]
```

### 订阅买卖盘信息

订阅某一种合约的买卖盘信息，分为两部分，首先推送买卖盘当前状态的快照，后续推送买卖盘的实时变动。

##### URL

[wss://ws.basefex.com/depth@{symbol}](wss://ws.basefex.com/depth@%7Bsymbol%7D)

##### 请求参数

| 参数     | 必选                   | 类型     | 说明                                                                                                                                                |
| ------ | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol | :white\_check\_mark: | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### 请求示例（使用wscat）

> wscat -c <wss://ws.basefex.com/depth@BTCUSD>

##### 返回示例

快照推送示例

``` js
{
    "to": 91277134,
    "bestPrices": {
        "ask": 11202.5,     // 卖盘最低价
        "bid": 11192.5      // 买盘最高价
    },
    "lastPrice": 11183.5,
    "bids": {
        "11192": 35,    
        "11184": 742,
        "11192.5": 389,     // 买盘最高价及订单数量
        "11188": 293
    },
    "asks": {
        "11202.5": 1806,    // 卖盘最低价
        "11212.5": 2138,
        "11211.5": 19308
    },
    "from": 0
}
```

实时推送示例

``` js
{
    "bids": {                   
        "11183": 3500
    },
    "lastPrice": 11183.5,
    "from": 91277135,
    "bestPrices": {         // 最优价
        "ask": 11202.5,
        "bid": 11192.5
    },
    "asks": {},
    "to": 91277135
}
```

### 订阅K线数据

根据时间粒度订阅某种合约的K线

##### URL

[wss://ws.basefex.com/candlesticks/{type}@{symbol}](wss://ws.basefex.com/candlesticks/%7Btype%7D@%7Bsymbol%7D)

##### 请求参数

| 参数     | 必选                   | 类型     | 说明                                                                                                                                                |
| ------ | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| type   | :white\_check\_mark: | string | 时间周期                                                                                                                                              |
| symbol | :white\_check\_mark: | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### 请求示例（使用wscat）

> wscat -c <wss://ws.basefex.com/candlesticks/1MIN@BTCUSD>

##### 返回示例

``` js
[
    {
        "symbol": "BTCUSD",           // 合约类型
        "type": "1MIN",               // 时间周期
        "time": 1562301000000,        // 当期开始时间
        "open": 11119.5,              // 开始价
        "close": 11109.5,             // 结束价
        "high": 11123.5,              // 当期最高价
        "low": 11109.5,               // 当期最低价
        "nTrades": 4,                 // 交易数量
        "volume": 3427,               // 交易量（单位美元）
        "turnover": 0.30820388075,    // 交易额（单位BTC）
        "version": 91383701,          // 
        "nextTs": 1562301060000       // 下一周期
    }
]
```

### 订阅交易记录

订阅平台的交易记录

##### URL

[wss://ws.basefex.com/trades@{symbol}](wss://ws.basefex.com/trades@%7Bsymbol%7D)

##### 请求参数

| 参数     | 必选                   | 类型     | 说明                                                                                                                                                |
| ------ | -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| symbol | :white\_check\_mark: | string | 合约类型，包括`BTCUSD`, `ETHXBT`, `XRPXBT`, `BCHXBT`, `LTCXBT`, `EOSXBT`, `ADAXBT`, `TRXXBT`, `BNBXBT`, `HTXBT`, `OKBXBT`, `GTXBT`, `ATOMXBT`, `BTCUSDT` |

##### 请求示例（使用wscat）

> wscat -c <wss://ws.basefex.com/trades@BTCUSD>

##### 返回示例

快照推送示例

``` js
[
    {
        "id": "5aefeab9-6840-0000-0001-0000056fe3c8", // 交易id
        "symbol": "BTCUSD",                           // 合约类型
        "price": 11178.5,                             // 
        "size": 100,                                  // 合约数量
        "matchedAt": 1562288776609,                   // 成交时间
        "side": "BUY"                                 // 买卖方向
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

实时推送示例

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

