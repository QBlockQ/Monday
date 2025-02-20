//
//  LightningNodeService.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import Foundation
import LDKNode
import SwiftUI

class LightningNodeService {
    private let ldkNode: LdkNode
    private let storageManager = LightningStorage()
    var networkColor = Color.black
    private let keyService: KeyClient

    class var shared: LightningNodeService {
        struct Singleton {
            static let instance = LightningNodeService(network: .signet)
        }
        return Singleton.instance
    }

    init(network: Network, keyService: KeyClient = .live) {

        try? FileManager.deleteLDKNodeLogLatestFile()

        let config = Config(
            storageDirPath: storageManager.getDocumentsDirectory(),
            network: network,
            listeningAddresses: ["0.0.0.0:9735"],
            defaultCltvExpiryDelta: UInt32(144),
            onchainWalletSyncIntervalSecs: UInt64(60),
            walletSyncIntervalSecs: UInt64(20),
            feeRateCacheUpdateIntervalSecs: UInt64(600),
            logLevel: .debug
        )
        let nodeBuilder = Builder.fromConfig(config: config)

        switch network {

        case .bitcoin:
            nodeBuilder.setGossipSourceRgs(
                rgsServerUrl: Constants.Config.RGSServerURLNetwork.bitcoin
            )
            nodeBuilder.setEsploraServer(
                esploraServerUrl: Constants.Config.EsploraServerURLNetwork.Bitcoin
                    .bitcoin_mempoolspace
            )
            self.networkColor = Constants.BitcoinNetworkColor.bitcoin.color

        case .regtest:
            nodeBuilder.setEsploraServer(
                esploraServerUrl: Constants.Config.EsploraServerURLNetwork.regtest
            )
            self.networkColor = Constants.BitcoinNetworkColor.regtest.color

        case .signet:
            nodeBuilder.setEsploraServer(
                esploraServerUrl: Constants.Config.EsploraServerURLNetwork.signet
            )
            self.networkColor = Constants.BitcoinNetworkColor.signet.color

        case .testnet:
            nodeBuilder.setGossipSourceRgs(
                rgsServerUrl: Constants.Config.RGSServerURLNetwork.testnet
            )
            nodeBuilder.setEsploraServer(
                esploraServerUrl: Constants.Config.EsploraServerURLNetwork.Testnet
                    .testnet_mempoolspace
            )
            self.networkColor = Constants.BitcoinNetworkColor.testnet.color

        }

        let backupInfo = try? keyService.getBackupInfo()
        if backupInfo?.mnemonic != nil {
            nodeBuilder.setEntropyBip39Mnemonic(mnemonic: backupInfo!.mnemonic, passphrase: nil)
        } else {
            let mnemonic = generateEntropyMnemonic()
            let backupInfo = BackupInfo(mnemonic: mnemonic)
            try? keyService.saveBackupInfo(backupInfo)
            nodeBuilder.setEntropyBip39Mnemonic(mnemonic: mnemonic, passphrase: nil)
        }

        // TODO: -!
        /// 06.22.23
        /// Breaking change in ldk-node 0.1 today
        /// `build` now `throws`
        /// - Resolve by actually handling error
        let ldkNode = try! nodeBuilder.build()

        self.ldkNode = ldkNode

        self.keyService = keyService
    }

    func start() async throws {
        try ldkNode.start()
    }

    func stop() throws {
        try ldkNode.stop()
    }

    func nodeId() -> String {
        let nodeID = ldkNode.nodeId()
        return nodeID
    }

    func newFundingAddress() async throws -> String {
        let fundingAddress = try ldkNode.newOnchainAddress()
        return fundingAddress
    }

    func getSpendableOnchainBalanceSats() async throws -> UInt64 {
        let balance = try ldkNode.spendableOnchainBalanceSats()
        return balance
    }

    func getTotalOnchainBalanceSats() async throws -> UInt64 {
        let balance = try ldkNode.totalOnchainBalanceSats()
        return balance
    }

    func connect(nodeId: PublicKey, address: String, persist: Bool) async throws {
        try ldkNode.connect(
            nodeId: nodeId,
            address: address,
            persist: persist
        )
    }

    func disconnect(nodeId: PublicKey) throws {
        try ldkNode.disconnect(nodeId: nodeId)
    }

    func connectOpenChannel(
        nodeId: PublicKey,
        address: String,
        channelAmountSats: UInt64,
        pushToCounterpartyMsat: UInt64?,
        channelConfig: ChannelConfig?,
        announceChannel: Bool = true
    ) async throws {
        try ldkNode.connectOpenChannel(
            nodeId: nodeId,
            address: address,
            channelAmountSats: channelAmountSats,
            pushToCounterpartyMsat: pushToCounterpartyMsat,
            channelConfig: nil,
            announceChannel: false
        )
    }

    func closeChannel(channelId: ChannelId, counterpartyNodeId: PublicKey) throws {
        try ldkNode.closeChannel(channelId: channelId, counterpartyNodeId: counterpartyNodeId)
    }

    func sendPayment(invoice: Bolt11Invoice) async throws -> PaymentHash {
        let paymentHash = try ldkNode.sendPayment(invoice: invoice)
        return paymentHash
    }

    func receivePayment(amountMsat: UInt64, description: String, expirySecs: UInt32) async throws
        -> Bolt11Invoice
    {
        let invoice = try ldkNode.receivePayment(
            amountMsat: amountMsat,
            description: description,
            expirySecs: expirySecs
        )
        return invoice
    }

    func listPeers() -> [PeerDetails] {
        let peers = ldkNode.listPeers()
        return peers
    }

    func listChannels() -> [ChannelDetails] {
        let channels = ldkNode.listChannels()
        return channels
    }

    func sendAllToOnchain(address: Address) async throws -> Txid {
        let txId = try ldkNode.sendAllToOnchainAddress(address: address)
        return txId
    }

    func listPayments() -> [PaymentDetails] {
        let payments = ldkNode.listPayments()
        return payments
    }

}

// Currently unused
extension LightningNodeService {

    func nextEvent() {
        let _ = ldkNode.nextEvent()
    }

    func eventHandled() {
        ldkNode.eventHandled()
    }

    func listeningAddresses() -> [String] {
        guard let addresses = ldkNode.listeningAddresses() else { return [] }
        return addresses
    }

    func sendToOnchainAddress(address: Address, amountMsat: UInt64) throws -> Txid {
        let txId = try ldkNode.sendToOnchainAddress(address: address, amountMsat: amountMsat)
        return txId
    }

    func sendAllToOnchainAddress(address: Address) throws -> Txid {
        let txId = try ldkNode.sendAllToOnchainAddress(address: address)
        return txId
    }

    func syncWallets() throws {
        try ldkNode.syncWallets()
    }

    func sendPaymentUsingAmount(invoice: Bolt11Invoice, amountMsat: UInt64) throws -> PaymentHash {
        let paymentHash = try ldkNode.sendPaymentUsingAmount(
            invoice: invoice,
            amountMsat: amountMsat
        )
        return paymentHash
    }

    func sendSpontaneousPayment(amountMsat: UInt64, nodeId: String) throws -> PaymentHash {
        let paymentHash = try ldkNode.sendSpontaneousPayment(amountMsat: amountMsat, nodeId: nodeId)
        return paymentHash
    }

    func receiveVariableAmountPayment(description: String, expirySecs: UInt32) throws
        -> Bolt11Invoice
    {
        let invoice = try ldkNode.receiveVariableAmountPayment(
            description: description,
            expirySecs: expirySecs
        )
        return invoice
    }

    func paymentInfo(paymentHash: PaymentHash) -> PaymentDetails? {
        guard let paymentDetails = ldkNode.payment(paymentHash: paymentHash) else { return nil }
        return paymentDetails
    }

    func removePayment(paymentHash: PaymentHash) throws {
        try ldkNode.removePayment(paymentHash: paymentHash)
    }

}

extension LightningNodeService {
    func deleteWallet() throws {
        try keyService.deleteBackupInfo()
    }
}
