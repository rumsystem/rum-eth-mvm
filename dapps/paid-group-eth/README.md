# ETH contract for Paid Group

## .env

```
DEPLOYER_PRIV_KEY="xxxxx"
DEPLOYER_PUB_KEY="xxxx"
USER1="xxxx"
QUORUM_CHAIN_ID="19890609"
QUORUM_RPC_URL="http://149.56.22.113:8545"
```

`USER1` 是测试用的一个私钥，可以通过 `test/utils.js` 中的 `newETHKey` 生成新的ETH账户。

## run task
Try running some of the following tasks:

```shell
npm run start
npm run compile
npm run test:hardhat
npm run deploy:hardhat
npm run deploy:quorum

npx hardhat help
```
