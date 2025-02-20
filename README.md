# Monday

[![License](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/reez/Monday/blob/master/LICENSE) 

An example iOS app using [LDK Node](https://github.com/lightningdevkit/ldk-node)

<img src="Docs/lightning-screen.png" alt="Screenshot" width="236" height="511">

## Functionality

This app is an experimental work in progress. 

It provides default implementations for: 
- testnet
- regtest *via [tnull](https://github.com/tnull/ldk-node-workshop)*
- signet *via [mutiny-net](https://github.com/MutinyWallet/mutiny-net)*

### Implemented

- [x] Start Node `start`

- [x] Stop Node `stop`

- [x] Node ID `nodeId`

- [x] Wallet Address `newFundingAddress`

- [x] Spendable Balance `getSpendableOnchainBalanceSats`

- [x] Total Balance `getTotalOnchainBalanceSats`

- [x] Connect Peer `connect`

- [x] Disconnect Peer `disconnect`

- [x] Open Channel `connectOpenChannel`

- [x] Close Channel `closeChannel`

- [x] Send `sendPayment`

- [x] Receive `receivePayment`

- [x] List Peers `listPeers`

- [x] List Channels `listChannels`

- [x] Send All Onchain `sendAllToOnchain`

- [x] List Payments `listPayments`

### Not Implemented

- [ ] Event Handling 

- [ ] All Payment variations

## Swift Packages

- LDK Node via [ldk-node](https://github.com/lightningdevkit/ldk-node)

- Bitcoin UI Kit via [BitcoinUI](https://github.com/reez/BitcoinUI)

- QR Code Scanner via [Code Scanner](https://github.com/twostraws/CodeScanner)

- Keychain via [Keychain Access](https://github.com/kishikawakatsumi/KeychainAccess)

## Thanks

[@notmandatory](https://github.com/notmandatory) for getting this up and running with me on a Monday.

[@tnull](https://github.com/tnull) most importantly. 

The [Lightning Dev Kit](https://lightningdevkit.org) team/project and the [Bitcoin Dev Kit](https://bitcoindevkit.org/) team/project, LDK Node is built using both.
