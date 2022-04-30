# PaidGroup

一個運行在 RUM-ETH-MVM 環境的 DApp 範例。這個項目展示針對 RUM-ETH-MVM 環境開發的細節。

## 通過官方 MVM API 代理調用 `（可通過 REST API 直接整合到現有應用）`

- Get Info of Paidgroup DApp
    ```bash
    http GET 'https://prs-bp2.press.one/api/dapps/PaidGroupMvm'
    ```
- Announce a Paidgroup
    ```bash
    echo '{
        "group": "[GROUP_UUID]",
        "owner": "[OWNER_ADDRESS]",
        "amount": "[CNB PRICE in STRING]",
        "duration": [SECONDS in INTEGER]
    }' | http POST 'https://prs-bp2.press.one/api/mvm/paidgroup/announce'

    # This testing DApp instant use CNB as settlement currency.
    ```
- Get Detail of a Paidgroup
    ```bash
    http GET 'https://prs-bp2.press.one/api/mvm/paidgroup/[GROUP_UUID]'
    ```
- Pay for a Paidgroup
    ```bash
    echo '{
        "user": "[USER_ADDRESS]",
        "group": "[GROUP_UUID]"
    }' | http POST 'https://prs-bp2.press.one/api/mvm/paidgroup/pay'
    ```
- Check Payment by `[GROUP_UUID]` and `[USER_ADDRESS]`
    ```bash
    http GET 'https://prs-bp2.press.one/api/mvm/paidgroup/[GROUP_UUID]/[USER_ADDRESS]'
    ```

## 直接調用 `（需要自己維護 MVM 環境）`

- 合约地址：0x95CB926eaDe1A04dFEC6fDfF7C2F6eDb46f32C39
- 部署的 block hash: 0xdf2ee98f39bad4d6977ba524eca9a634fb46b99f8108a12919f903c8957be63c

<details>
    <summary>合约调用</summary>

### 环境说明

环境变量：
```
mvm_conf_path="mvm.toml"  # MVM 群組配置文件
keystore_path="keystore_1.json"  # 開發者微信錢包配置
new_keystore_path="keystore_2.json"  # 用於託管 MVM APP 的微信錢包配置
```

部署使用的 `keystore`，放在 `$new_keystore_path`，该 `keystore` 是通过 `mixin-cli -f $keystore_path user create app_prod_paid_group | tee $new_keystore_path` 生成的。内容如下：

```
{
  "client_id": "3f7faae9-4c73-37cc-8904-xxxxxxxxxxxx",
  "session_id": "ba77661b-002e-46ed-a592-xxxxxxxxxxxx",
  "private_key": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "pin_token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "scope": "",
  "pin": "xxxxxx"
}
```

从上面文件中获取 `client_id`:

```
client_id=$(grep client_id $new_keystore_path | grep -Po '(\w+\-?)+' | tail -n1)
client_id_hex=$(echo $client_id | sed -e 's/-//g' -e 's/^/0x/')  # 合约中 PID 的值
```

部署合约的hash：0x1b337bd714303bad078d451e1e3977dae51124eed5e95d54cb8d6fc45a863716
合约地址：0x802d74ade2dce49f7205d2fab2196a68de10f697

### mvm publish

```
mvm publish -m $mvm_conf_path -k $new_keystore_path -a 0x802d74ADE2DCE49f7205d2fAb2196A68De10F697 -e 0x1b337bd714303bad078d451e1e3977dae51124eed5e95d54cb8d6fc45a863716
```

### mvm invoke

可以修改 `parse_extra.py` 中的值，运行该脚本生成 或 解析。

#### announce group price

```
mvm invoke -m $mvm_conf_path -k $new_keystore_path -p $client_id -e 00eea91a66b42d47eab752af98b9e6391bcc224ef7341992368fe95c82d3588ae40fbbb614000000003b9aca0001e13380
```

`-e extra` 参数说明：
- 十六进制字符串的长度是：98；49 字节
- 十六进制的前两位是 action，0 - announce group price; 1 - pay group
- 之后的32位是 `group id`，quorum 的 group id 是 uuid4，将它转换成十六进制，就是 32位十六进制的字符串
- 之后的40位是 `quorum用户地址 - eth address`，这里代表 `group owner` 的quorum address
- 之后的16位是 `group price`
- 之后的8位是有效期；比如，支付后多久过期，需要再次购买，单位是秒；(2 ** 32 -1) / (365 * 24 * 60 * 60) = 136.1925，应该也够用了

#### 支付 group 费用

```
mvm invoke -m $mvm_conf_path -k $new_keystore_path -p $client_id -e 01eea91a66b42d47eab752af98b9e6391b729d862c8a47e0600e35fd4acef14e2b00b9d0cd000000000000000000000000
```

`-e extra` 参数说明：
- 十六进制的前两位是 action，0 - announce group price; 1 - pay group
- 之后的32位是 `group id`，quorum 的 group id 是 uuid4，将它转换成十六进制，就是 32位十六进制的字符串
- 之后的40位是 `quorum用户地址 - eth address`，这里代表 `group owner` 的quorum address
- 之后的16位是 `group price`，这里是 0
- 之后的16位是有效期；比如，支付后多久过期，需要再次购买；这里为 0

### web3 invoke

参考压缩包中的 `demo.py`

</details>
