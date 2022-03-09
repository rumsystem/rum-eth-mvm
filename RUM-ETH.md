# RUM-ETH

An [ETH](https://ethereum.org/) (POA) Network is being maintained by [RumSystem.net](RumSystem.net).

## Ethereum

- Blockchain Explorer: [`https://explorer.rumsystem.net`](https://explorer.rumsystem.net)
- RPC API: `http://149.56.22.113:8545`
- Chain ID: `19890609`
- Genesis JSON: [`https://raw.githubusercontent.com/Press-One/rum-eth/main/public/quorum.json`](https://raw.githubusercontent.com/Press-One/rum-eth/main/public/quorum.json)
- Boot Node: `enode://3cd11a5dd80a59158f0f1baea9c0ce4928815ccfc4f888b27e4aaec99fe9143892c2c485de4f77a21442506da00473955c619374f17a26fc1d2b96ad4ace6542@149.56.22.113:30303`

## Launch a Node

```bash
TEMP_PATH=`mktemp -d`
TEMP_PORT=`shuf -n 1 -i 49152-65535`
geth --datadir $TEMP_PATH init quorum.json
geth \
    --datadir $TEMP_PATH \
    --networkid 19890609 \
    --port $TEMP_PORT \
    --bootnodes 'enode://3cd11a5dd80a59158f0f1baea9c0ce4928815ccfc4f888b27e4aaec99fe9143892c2c485de4f77a21442506da00473955c619374f17a26fc1d2b96ad4ace6542@149.56.22.113:30303'
```
