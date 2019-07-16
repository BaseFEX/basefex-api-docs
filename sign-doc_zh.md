### 生成 API 密钥

从这个地址获取新的密钥 [https://www.basefex.com/account/keys](https://www.basefex.com/account/keys)。获取时需要双重验证，可以使用 Google Authenticator 或者 Authy。 将生成的密钥及其ID保管好，使用两者计算Token以获取API请求权限。

# `API密钥`使用方法

使用`API密钥`对请求进行签名认证。

### HTTP 头部信息

- `api-expires`: 过期时间，使用 Unix 时间戳。

最小单位为秒，例如 UTC 时间 2019-07-11 07:52:34 对应的时间戳是 1562831554。这个时间戳与服务器端时间进行对比，如果过期，请求将被拒绝。

- `api-key`: 密钥的id。

- `api-signature`: 根据本地请求的内容计算出的签名，计算公式为 hex(HMAC_SHA256(apiSecret, verb + path + expires + data))。具体请看一下Python代码示例。

###  `signature`示例

```python
apiKey = '5afd4095-f1fb-41d0-0005-1a0048ffe468'            # 密钥id
apiSecret = 'OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is=' # 密钥

#
# Simple GET
#
verb = 'GET'
path = '/accounts'
expires = 1563148118 # 2019-07-14 23:28:38
data = ''

# HEX(HMAC_SHA256(apiSecret, 'GET/accounts1563148118'))
# Result is:
# ''
signature = HEX(HMAC_SHA256(apiSecret, verb + path + str(expires) + data))
```

### 计算Token示例代码

Python
```python
from datetime import datetime
import hashlib
import hmac
from urllib.parse import urlparse

# 先哈希 HMAC_SHA256(secret, verb + path + expires + data)，再将字节数组编码为成16进制字符串即为signature
# verb是HTTP方法，必须为英文大写；url为相对路径；expires为Unix时间戳，单位为秒。
# data为不带空格的json字符串
def generate_signature(secret, verb, url, expires, data):
    # 解析url获取相对路径
    parsedURL = urlparse(url)
    path = parsedURL.path
    if parsedURL.query:
        path = path + '?' + parsedURL.query

    if isinstance(data, (bytes, bytearray)):
        data = data.decode('utf8')

    print("Computing HMAC: %s" % verb + path + str(expires) + data)
    message = verb + path + str(expires) + data

    signature = hmac.new(bytes(secret, 'utf8'), bytes(message, 'utf8'), digestmod=hashlib.sha256).hexdigest()
    return signature

# 密钥
secret = "OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is="
# expires = 1563148118
# 或者从当前时间之后的一段时间有效
# 下边的时间戳5秒之后失效
timestamp = datetime.now().timestamp()
expires = int(round(timestamp) + 5)

print(generate_signature(secret, 'GET', '/accounts', expires, ''))
# c321f340c6356dd562c12d16abacceeb8483b5dea9c2735f7abc85ea696b91a5
```

#### 获取账户余额和仓位信息

```python
key_id = '5afd4095-f1fb-41d0-0005-1a0048ffe468'  # replace with your key id
secret = "OJJFq6qugIyvLBOyvg8WBPriSs0Dfw7Mi3QjLYin8is=" # replace with your key
url = 'https://next-api.basefex.com/accounts'
auth_token = generate_signature(secret, "GET", "/accounts", expires, '')
hed = {'api-expires':str(expires),'api-key':key_id,'api-signature':str(auth_token)}
response = requests.get(url, headers=hed)
print(response.json())

```