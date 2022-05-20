# RUM Payment Gateway

An official payment gateway implementation based on [RumERC20 DApp](https://github.com/Press-One/rum-eth-mvm/tree/main/dapps/RumERC20).

RUM Payment Gateway is fully Compatible with [ERC20 standard](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/).

## API:

- Request Fee
    ```bash
    $ echo '{
        "account": "[ACCOUNT_ADDRESS]"
    }' | http POST 'https://prs-bp2.press.one/api/coins/fee'
    ```
- Get Account Information
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/accounts/[ACCOUNT_ADDRESS]'
    ```
- Get Bound Payment Accounts
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/accounts/[ACCOUNT_ADDRESS]/bounds'
    ```
- Bind Mixin Payment Account (if you know the Mixin-Account-UUID)
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/accounts/bind?provider=mixin&id=[MIXIN_ID]
    ```
- Bind Mixin Payment Account (if you DO NOT know the Mixin-Account-UUID)
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/accounts/bind?provider=mixin
    ```
- Get all Mirrored Coins
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/coins/mirrored'
    ```
- Deposit
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/coins/deposit?asset=[COIN_SYMBOL]&amount=[AMOUNT]&account=[ACCOUNT_ADDRESS]'
    ```
- Transfer
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/coins/transfer?asset=[COIN_SYMBOL]&amount=[AMOUNT]&to=[ACCOUNT_ADDRESS]'
    ```
- Get Transactions
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/coins/transactions?asset=[COIN_SYMBOL|OPTIONAL]&account=[ACCOUNT_ADDRESS|OPTIONAL]'
- Withdraw
    ```bash
    $ http GET 'https://prs-bp2.press.one/api/coins/withdraw?asset=[COIN_SYMBOL]&amount=[AMOUNT]'
    ```
