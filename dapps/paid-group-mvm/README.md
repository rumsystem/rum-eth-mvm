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

- [Development](Development.md)
