# PaidGroup

一個運行在 RUM-ETH-MVM 環境的 DApp 範例。這個項目展示針對 RUM-ETH-MVM 環境開發的細節。

## 通過官方 MVM API 代理調用`（可通過 REST API 直接整合到現有應用）`

- Announce a Paidgroup
    ```bash
    echo '{
        "group": "[GROUP_UUID]",
        "owner": "[OWNER_ADDRESS]",
        "amount": "[CNB PRICE in STRING]",
        "duration": [SECONDS in INTEGER]
    }' | http POST 'https://prs-bp2.press.one/api/paidgroup/announce'

    # This testing DApp instant use CNB as settlement currency.
    ```
- Get Detail of a Paidgroup
    ```bash
    http GET 'https://prs-bp2.press.one/api/paidgroup/[GROUP_UUID]'
    ```
- Pay for a Paidgroup
    ```bash
    echo '{
        "user": "[USER_ADDRESS]",
        "group": "[GROUP_UUID]"
    }' | http POST 'https://prs-bp2.press.one/api/api/paidgroup/pay'
    ```
- Check Payment by `[GROUP_UUID]` and `[USER_ADDRESS]`
    ```bash
    http GET 'https://prs-bp2.press.one/api/paidgroup/[GROUP_UUID]/[USER_ADDRESS]'
    ```

## 直接調用`（需要自己維護 MVM 環境）`

- [Development](Development.md)
