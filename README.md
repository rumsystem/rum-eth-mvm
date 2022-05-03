# RUM-ETH-MVM

This is a docset repo containing everything you need to know about developing DApps works in RUM, ETH and MVM environments.

## Topology

![Topology](/assets/Topology.svg) <!-- https://app.diagrams.net/#HPress-One%2Frum-eth-mvm%2Fmain%2FTopology.drawio -->

## Environments

- [Quorum Infrastructure: The internet alternatives](https://github.com/rumsystem/quorum)
- [RUM-ETH: An ETH Network is being maintained by the team behind Quorum](RUM-ETH.md)
- [RUM-MVM: A MVM Network is being tested by the team behind Quorum](RUM-MVM.md)

## Development Workflow

1. Deploy an `EVM Compatible Contract` on [RUM-ETH](RUM-ETH.md).
1. [Publish](RUM-MVM.md) the `Contract` as a `MVM-APP`.
1. [Invoke](RUM-MVM.md) the `MVM-APP` in your project.
1. [Trace](RUM-ETH.md) the `Contract Status` on `RUM-ETH`.

## DApps

- [PaidGroupEth](https://github.com/Press-One/rum-eth-mvm/tree/main/dapps/paid-group-eth)
- [PaidGroupMvm](https://github.com/Press-One/rum-eth-mvm/tree/main/dapps/paid-group-mvm)
- [RumAccount](https://github.com/Press-One/rum-eth-mvm/tree/main/dapps/RumAccount)
- [RumERC20](https://github.com/Press-One/rum-eth-mvm/tree/main/dapps/RumERC20)
- [RumSC](https://github.com/Press-One/rum-eth-mvm/tree/main/dapps/RumSC)

## Payment Gateway

- [API](https://github.com/Press-One/rum-eth-mvm/blob/main/PAYMENT-GATEWAY.md)
