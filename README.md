# rum-eth

A ETH (POA) Network which is being maintained by RumSystem.net


## Ethereum

- Blockchain Explorer: [`https://explorer.rumsystem.net`](https://explorer.rumsystem.net)
- RPC API: `http://149.56.22.113:8545`
- Chain ID: `19890609`
- Genesis JSON: [`https://raw.githubusercontent.com/Press-One/rum-eth/main/quorum.json`](https://raw.githubusercontent.com/Press-One/rum-eth/main/quorum.json)
- Boot Node: `enode://3cd11a5dd80a59158f0f1baea9c0ce4928815ccfc4f888b27e4aaec99fe9143892c2c485de4f77a21442506da00473955c619374f17a26fc1d2b96ad4ace6542@149.56.22.113:30303`


## Run a Node

```
$ geth \
    --datadir /tmp/rum-eth-full \
    --networkid 19890609 \
    --syncmode 'full' \
    --gcmode=archive \
    --snapshot=true \
    --maxpeers 10000000 \
    --port 30303 \
    --http \
    --http.addr '0.0.0.0' \
    --http.port 8545 \
    --http.corsdomain '*' \
    --http.vhosts '*' \
    --http.api 'debug,net,eth,shh,web3,txpool' \
    --graphql \
    --graphql.corsdomain '*' \
    --graphql.vhosts '*' \
    --ws --ws.addr '0.0.0.0' \
    --ws.port 3334 \
    --ws.origins '*' \
    --ws.api 'eth,net,web3,network,debug,txpool' \
    --bootnodes 'enode://3cd11a5dd80a59158f0f1baea9c0ce4928815ccfc4f888b27e4aaec99fe9143892c2c485de4f77a21442506da00473955c619374f17a26fc1d2b96ad4ace6542@149.56.22.113:30303'"
```
