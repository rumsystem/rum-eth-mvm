# RUM-MVM

A [MVM](https://github.com/MixinNetwork/trusted-group/tree/master/mvm/) Network is being maintained by [RumSystem.net](RumSystem.net).

`This MVM network is being tested currently. All nodes are under control by RumSystem.net in beta stage.`

## MVM

- MVM TOML: [`https://raw.githubusercontent.com/Press-One/rum-eth-mvm/main/mvm.toml`](https://raw.githubusercontent.com/Press-One/rum-eth-mvm/main/mvm.toml)

## Development Workflow (to debug your contract via Mixin bot)

- Deploy Contract (https://remix.ethereum.org/)
- Add this bot (7000100209) as a contact in your Mixin app.
- Apply for a New Bot to Host MVM-APP: `MVM BOT`
    <img width="700" alt="Screen Shot 2022-02-15 at 7 41 23 PM" src="https://user-images.githubusercontent.com/233022/154175020-9a1ab4ea-c848-492f-891c-897446edb388.png">
    <img width="700" alt="Screen Shot 2022-02-15 at 7 41 28 PM" src="https://user-images.githubusercontent.com/233022/154175069-8965d655-772d-4729-ab8d-badefaa7293f.png">
- Publish Contract as a New MVM-APP: `MVM PUB [CONTRACT ADDRESS] [CONTRACT HASH] [KEYSTORE]`
    <img width="700" alt="Screen Shot 2022-02-15 at 7 41 41 PM" src="https://user-images.githubusercontent.com/233022/154175119-cb85bff0-1424-4dec-a462-60af5fcaedff.png">
- Invoke a MVM-APP: `MVM INVOKE [MVM-APP-ID | 'APP ID' in 'MVM PUB' response] [EXTRA | OPTIONAL]`
    <img width="700" alt="Screen Shot 2022-01-12 at 11 14 51 PM" src="https://user-images.githubusercontent.com/233022/157370763-a486563b-3b10-475c-933e-fbfda239caba.png">

## Development Workflow (integrate with your APP via HTTP APIs)

- Deploy Contract (https://remix.ethereum.org/)
- Apply for a New Bot to Host MVM-APP
```bash
echo '{}' | http POST 'https://prs-bp2.press.one/api/mvm/applybot'
```
- Publish Contract as a New MVM-APP
```bash
echo '{
    "contractAddress": "0xf0e75e53f0aec66e9536c7d9c7afcdb140acde19",
    "contractHash": "0x2df088da5a766320e3f712c0babac1e493899453a719fe9b1578d44350d7499a",
    "keystore": {
        "client_id":"1b40c257-0752-3821-a8bc-387c9f95c6dd",
        "session_id":"650e5ad0-a3e5-4b1b-b531-5c6f91b431cf",
        "private_key":"DnsHbO1yp1Ez3AiLxXaY2DbMfy374HE9VmBKQabJrr9LLvlrwvtxY8/DeY+BKWZUiSbhh8Hk0gfw/uOJBWUz8w==",
        "pin_token":"m2r8LiVVHnQmFbSj/QlFQL7ENIh415Z+oc5o/dZ11xQ=",
        "scope":"",
        "pin":"212159"
    }
}' | http POST 'https://prs-bp2.press.one/api/mvm/publish'
```
- Invoke a MVM-APP
```bash
echo '{"extra": "SELF_ENCODED_ARGS_LENGTH<=98"}' | http POST 'https://prs-bp2.press.one/api/mvm/eb2ee7fe-8ff4-38e3-82c2-76c6ef94f1f8/invoke'
```

## Under The Hook

- [Testing Environment](TEST_ENV.md)
- [Production Environment](PROD_ENV.md)
