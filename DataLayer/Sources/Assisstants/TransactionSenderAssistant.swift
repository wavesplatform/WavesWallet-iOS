//
//  TransactionAssistant.swift
//  DataLayer
//
//  Created by Pavel Gubin on 06.07.2019.
//

import DomainLayer
import Foundation
import WavesSDK
import WavesSDKCrypto
import WavesSDKExtensions

extension TransactionSenderSpecifications {
    private func chainId(serverEnvironment: ServerEnvironment,
                         specifications: TransactionSenderSpecifications) -> String {
        return specifications.chainId ?? serverEnvironment.kind.chainId
    }

    private func timestamp(specifications: TransactionSenderSpecifications) -> Date {
        return specifications.timestamp ?? Date()
    }

    func broadcastSpecification(serverEnvironment: ServerEnvironment,
                                wallet: SignedWallet,
                                specifications: TransactionSenderSpecifications) -> NodeService.Query.Transaction? {
        let timestampServerDiff = serverEnvironment.timestampServerDiff

        let scheme = chainId(serverEnvironment: serverEnvironment,
                             specifications: specifications)

        let timestamp = self.timestamp(specifications: specifications)
            .millisecondsSince1970(timestampDiff: timestampServerDiff)

        var signature = self.signature(timestamp: timestamp,
                                       scheme: scheme,
                                       publicKey: wallet.publicKey.publicKey)

        do {
            signature = try wallet.sign(input: signature, kind: [.none])
        } catch let e {
            SweetLogger.error(e)
            return nil
        }

        let proofs = [Base58Encoder.encode(signature)]

        let broadcastSpecification = continueBroadcastSpecification(timestamp: timestamp,
                                                                    scheme: serverEnvironment.kind.chainId,
                                                                    aliasScheme: serverEnvironment.aliasScheme,
                                                                    publicKey: wallet.publicKey.getPublicKeyStr(),
                                                                    proofs: proofs)
        return broadcastSpecification
    }

    private func continueBroadcastSpecification(timestamp: Int64,
                                                scheme: String,
                                                aliasScheme: String,
                                                publicKey: String,
                                                proofs: [String]) -> NodeService.Query.Transaction {
        switch self {
        case let .burn(model):

            return .burn(NodeService.Query.Transaction.Burn(version: version,
                                                            chainId: scheme,
                                                            fee: model.fee,
                                                            assetId: model.assetID,
                                                            quantity: model.quantity,
                                                            timestamp: timestamp,
                                                            senderPublicKey: publicKey,
                                                            proofs: proofs))

        case let .createAlias(model):

            return .createAlias(NodeService.Query.Transaction.Alias(version: version,
                                                                    chainId: scheme,
                                                                    name: model.alias,
                                                                    fee: model.fee,
                                                                    timestamp: timestamp,
                                                                    senderPublicKey: publicKey,
                                                                    proofs: proofs))
        case let .lease(model):

            var recipient = ""
            if model.recipient.count <= WavesSDKConstants.aliasNameMaxLimitSymbols {
                recipient = aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            return .startLease(NodeService.Query.Transaction.Lease(version: version,
                                                                   chainId: scheme,
                                                                   fee: model.fee,
                                                                   recipient: recipient,
                                                                   amount: model.amount,
                                                                   timestamp: timestamp,
                                                                   senderPublicKey: publicKey,
                                                                   proofs: proofs))
        case let .cancelLease(model):

            return .cancelLease(NodeService.Query.Transaction.LeaseCancel(version: version,
                                                                          chainId: scheme,
                                                                          fee: model.fee,
                                                                          leaseId: model.leaseId,
                                                                          timestamp: timestamp,
                                                                          senderPublicKey: publicKey,
                                                                          proofs: proofs))

        case let .data(model):

            return .data(NodeService.Query.Transaction.Data(version: version,
                                                            fee: model.fee,
                                                            timestamp: timestamp,
                                                            senderPublicKey: publicKey,
                                                            proofs: proofs,
                                                            data: model.dataForNode,
                                                            chainId: scheme))

        case let .send(model):
            let recipient: String

            if model.recipient.count <= WavesSDKConstants.aliasNameMaxLimitSymbols {
                recipient = aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }

            let attachment = Base58Encoder.encode(Array(model.attachment.utf8))
            return .transfer(NodeService.Query.Transaction.Transfer(version: version,
                                                                    recipient: recipient,
                                                                    assetId: model.assetId,
                                                                    amount: model.amount,
                                                                    fee: model.fee,
                                                                    attachment: attachment,
                                                                    feeAssetId: model.getFeeAssetID,
                                                                    timestamp: timestamp,
                                                                    senderPublicKey: publicKey,
                                                                    proofs: proofs,
                                                                    chainId: scheme))

        case let .invokeScript(model):
            var call: NodeService.Query.Transaction.InvokeScript.Call?

            if let localCall = model.call {
                let args = localCall.args.map { arg -> NodeService.Query.Transaction.InvokeScript.Arg in

                    let value: NodeService.Query.Transaction.InvokeScript.Arg.Value = { ()
                        -> NodeService.Query.Transaction.InvokeScript.Arg.Value in

                        switch arg.value {
                        case let .binary(value):
                            return .binary(value)

                        case let .bool(value):
                            return .bool(value)

                        case let .integer(value):
                            return .integer(value)

                        case let .string(value):
                            return .string(value)
                        }
                    }()

                    return .init(value: value)
                }

                call = NodeService.Query.Transaction.InvokeScript.Call(function: localCall.function,
                                                                       args: args)
            }

            let payment = model.payment.map {
                NodeService.Query.Transaction.InvokeScript.Payment(amount: $0.amount, assetId: $0.assetId)
            }

            return .invokeScript(.init(version: version,
                                       chainId: scheme,
                                       fee: model.fee,
                                       timestamp: timestamp,
                                       senderPublicKey: publicKey,
                                       feeAssetId: model.feeAssetId,
                                       proofs: proofs,
                                       dApp: model.dApp,
                                       call: call,
                                       payment: payment))
        }
    }

    func signature(timestamp: Int64, scheme: String, publicKey: [UInt8]) -> [UInt8] {
        switch self {
        case let .data(model):

            let bytes = TransactionSignatureV1.data(.init(fee: model.fee,
                                                          data: model.dataForSignature,
                                                          chainId: scheme,
                                                          senderPublicKey: Base58Encoder.encode(publicKey),
                                                          timestamp: timestamp)).bytesStructure

            return bytes

        case let .burn(model):

            let bytes = TransactionSignatureV2.burn(.init(assetID: model.assetID,
                                                          quantity: model.quantity,
                                                          fee: model.fee,
                                                          chainId: scheme,
                                                          senderPublicKey: Base58Encoder.encode(publicKey),
                                                          timestamp: timestamp)).bytesStructure

            return bytes

        case let .cancelLease(model):

            let bytes = TransactionSignatureV2.cancelLease(.init(leaseId: model.leaseId,
                                                                 fee: model.fee,
                                                                 chainId: scheme,
                                                                 senderPublicKey: Base58Encoder.encode(publicKey),
                                                                 timestamp: timestamp)).bytesStructure

            return bytes

        case let .createAlias(model):

            let bytes = TransactionSignatureV2.createAlias(.init(alias: model.alias,
                                                                 fee: model.fee,
                                                                 chainId: scheme,
                                                                 senderPublicKey: Base58Encoder.encode(publicKey),
                                                                 timestamp: timestamp)).bytesStructure

            return bytes

        case let .lease(model):

            let bytes = TransactionSignatureV2.startLease(.init(recipient: model.recipient,
                                                                amount: model.amount,
                                                                fee: model.fee,
                                                                chainId: scheme,
                                                                senderPublicKey: Base58Encoder.encode(publicKey),
                                                                timestamp: timestamp)).bytesStructure

            return bytes

        case let .send(model):

            let bytes = TransactionSignatureV2.transfer(.init(senderPublicKey: Base58Encoder.encode(publicKey),
                                                              recipient: model.recipient,
                                                              assetId: model.assetId,
                                                              amount: model.amount,
                                                              fee: model.fee,
                                                              attachment: Base58Encoder.encode(Array(model.attachment.utf8)),
                                                              feeAssetID: model.feeAssetID,
                                                              chainId: scheme,
                                                              timestamp: timestamp))
                .bytesStructure

            return bytes

        case let .invokeScript(model):

            var call: TransactionSignatureV1.Structure.InvokeScript.Call?

            if let localCall = model.call {
                let args = localCall.args.map { arg -> TransactionSignatureV1.Structure.InvokeScript.Arg in

                    let value = { () -> TransactionSignatureV1.Structure.InvokeScript.Arg.Value in

                        switch arg.value {
                        case let .binary(value):
                            return .binary(value)

                        case let .integer(value):
                            return .integer(value)

                        case let .bool(value):
                            return .bool(value)

                        case let .string(value):
                            return .string(value)
                        }
                    }()

                    return TransactionSignatureV1.Structure.InvokeScript.Arg(value: value)
                }

                call = TransactionSignatureV1.Structure.InvokeScript.Call(function: localCall.function,
                                                                          args: args)
            }

            let payment = model.payment.map {
                TransactionSignatureV1.Structure.InvokeScript.Payment(amount: $0.amount, assetId: $0.assetId)
            }

            let bytes = TransactionSignatureV1.invokeScript(.init(senderPublicKey: Base58Encoder.encode(publicKey),
                                                                  fee: model.fee,
                                                                  chainId: scheme,
                                                                  timestamp: timestamp,
                                                                  feeAssetId: model.feeAssetId,
                                                                  dApp: model.dApp,
                                                                  call: call,
                                                                  payment: payment))
                .bytesStructure

            return bytes
        }
    }
}

private extension SendTransactionSender {
    var getFeeAssetID: String {
        feeAssetID == WavesSDKConstants.wavesAssetId ? "" : feeAssetID
    }
}

private extension DataTransactionSender {
    var dataForSignature: [TransactionSignatureV1.Structure.Data.Value] {
        data.map { value -> TransactionSignatureV1.Structure.Data.Value in
            let kind: TransactionSignatureV1.Structure.Data.Value.Kind

            switch value.value {
            case let .binary(data):
                kind = .binary(data)

            case let .integer(number):
                kind = .integer(number)

            case let .boolean(flag):
                kind = .boolean(flag)

            case let .string(str):
                kind = .string(str)
            }

            return TransactionSignatureV1.Structure.Data.Value(key: value.key, value: kind)
        }
    }

    var dataForNode: [NodeService.Query.Transaction.Data.Value] {
        data.map { value -> NodeService.Query.Transaction.Data.Value in
            let kind: NodeService.Query.Transaction.Data.Value.Kind

            switch value.value {
            case let .binary(data):
                kind = .binary(data)

            case let .integer(number):
                kind = .integer(number)

            case let .boolean(flag):
                kind = .boolean(flag)

            case let .string(str):
                kind = .string(str)
            }

            return NodeService.Query.Transaction.Data.Value(key: value.key, value: kind)
        }
    }
}
