//
//  TransactionAssistant.swift
//  DataLayer
//
//  Created by Pavel Gubin on 06.07.2019.
//

import Foundation
import DomainLayer
import WavesSDK
import WavesSDKExtensions
import WavesSDKCrypto

extension TransactionSenderSpecifications {
    
    func broadcastSpecification(servicesEnvironment: ApplicationEnviroment,
                                wallet: DomainLayer.DTO.SignedWallet,
                                specifications: TransactionSenderSpecifications) -> NodeService.Query.Transaction? {
        
        let walletEnvironment = servicesEnvironment.walletEnvironment
        let timestampServerDiff = servicesEnvironment.timestampServerDiff
        
        let timestamp = Date().millisecondsSince1970(timestampDiff: timestampServerDiff)
        var signature = self.signature(timestamp: timestamp,
                                       scheme: servicesEnvironment.walletEnvironment.scheme,
                                       publicKey: wallet.publicKey.publicKey)
        
        do {
            signature = try wallet.sign(input: signature, kind: [.none])
        } catch let e {
            SweetLogger.error(e)
            return nil
        }
        
        let proofs = [Base58Encoder.encode(signature)]
        
        let broadcastSpecification = self.continueBroadcastSpecification(timestamp: timestamp,
                                                                         environment: walletEnvironment,
                                                                         publicKey: wallet.publicKey.getPublicKeyStr(),
                                                                         proofs: proofs)
        return broadcastSpecification
    }
    
    private func continueBroadcastSpecification(timestamp: Int64,
                                                environment: WalletEnvironment,
                                                publicKey: String,
                                                proofs: [String]) -> NodeService.Query.Transaction {
        
        switch self {
            
        case .burn(let model):
            
            return .burn(NodeService.Query.Transaction.Burn(version: self.version,
                                                            chainId: environment.scheme,
                                                            fee: model.fee,
                                                            assetId: model.assetID,
                                                            quantity: model.quantity,
                                                            timestamp: timestamp,
                                                            senderPublicKey: publicKey,
                                                            proofs: proofs))
            
        case .createAlias(let model):
            
            return .createAlias(NodeService.Query.Transaction.Alias(version: self.version,
                                                                    chainId: environment.scheme,
                                                                    name: model.alias,
                                                                    fee: model.fee,
                                                                    timestamp: timestamp,
                                                                    senderPublicKey: publicKey,
                                                                    proofs: proofs))
        case .lease(let model):
            
            var recipient = ""
            if model.recipient.count <= WavesSDKConstants.aliasNameMaxLimitSymbols {
                recipient = environment.aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            return .startLease(NodeService.Query.Transaction.Lease(version: self.version,
                                                                   chainId: environment.scheme,
                                                                   fee: model.fee,
                                                                   recipient: recipient,
                                                                   amount: model.amount,
                                                                   timestamp: timestamp,
                                                                   senderPublicKey: publicKey,
                                                                   proofs: proofs))
        case .cancelLease(let model):
            
            return .cancelLease(NodeService.Query.Transaction.LeaseCancel(version: self.version,
                                                                          chainId: environment.scheme,
                                                                          fee: model.fee,
                                                                          leaseId: model.leaseId,
                                                                          timestamp: timestamp,
                                                                          senderPublicKey: publicKey,
                                                                          proofs: proofs))
            
        case .data(let model):
            
            return .data(NodeService.Query.Transaction.Data(version: self.version,
                                                            fee: model.fee,
                                                            timestamp: timestamp,
                                                            senderPublicKey: publicKey,
                                                            proofs: proofs,
                                                            data: model.dataForNode,
                                                            chainId: environment.scheme))
            
        case .send(let model):
            
            var recipient = ""
            if model.recipient.count <= WavesSDKConstants.aliasNameMaxLimitSymbols {
                recipient = environment.aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            
            return .transfer(NodeService.Query.Transaction.Transfer(version: self.version,
                                                                    recipient: recipient,
                                                                    assetId: model.assetId,
                                                                    amount: model.amount,
                                                                    fee: model.fee,
                                                                    attachment: Base58Encoder.encode(Array(model.attachment.utf8)),
                                                                    feeAssetId: model.getFeeAssetID,
                                                                    timestamp: timestamp,
                                                                    senderPublicKey: publicKey,
                                                                    proofs: proofs,
                                                                    chainId: environment.scheme))
        }
        
    }
    
    private func signature(timestamp: Int64, scheme: String, publicKey: [UInt8]) -> [UInt8] {
        
        switch self {
            
        case .data(let model):
            
            let bytes = TransactionSignatureV1.data(.init(fee: model.fee,
                                                          data: model.dataForSignature,
                                                          chainId: scheme,
                                                          senderPublicKey: Base58Encoder.encode(publicKey),
                                                          timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .burn(let model):
            
            let bytes = TransactionSignatureV2.burn(.init(assetID: model.assetID,
                                                          quantity: model.quantity,
                                                          fee: model.fee,
                                                          chainId: scheme,
                                                          senderPublicKey: Base58Encoder.encode(publicKey),
                                                          timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .cancelLease(let model):
            
            let bytes = TransactionSignatureV2.cancelLease(.init(leaseId: model.leaseId,
                                                                 fee: model.fee,
                                                                 chainId: scheme,
                                                                 senderPublicKey: Base58Encoder.encode(publicKey),
                                                                 timestamp: timestamp)).bytesStructure
            
            return bytes
            
            
        case .createAlias(let model):
            
            let bytes = TransactionSignatureV2.createAlias(.init(alias: model.alias,
                                                                 fee: model.fee,
                                                                 chainId: scheme,
                                                                 senderPublicKey: Base58Encoder.encode(publicKey),
                                                                 timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .lease(let model):
            
            let bytes = TransactionSignatureV2.startLease(.init(recipient: model.recipient,
                                                                amount: model.amount,
                                                                fee: model.fee,
                                                                chainId: scheme,
                                                                senderPublicKey: Base58Encoder.encode(publicKey),
                                                                timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .send(let model):
            
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
        }
    }
}


private extension SendTransactionSender {
    
    var getFeeAssetID: String {
        return feeAssetID == WavesSDKConstants.wavesAssetId ? "" : feeAssetID
    }
}

private extension DataTransactionSender {
    
    var dataForSignature: [TransactionSignatureV1.Structure.Data.Value] {
        return self.data.map({ (value) -> TransactionSignatureV1.Structure.Data.Value in
            
            var kind: TransactionSignatureV1.Structure.Data.Value.Kind!
            
            switch value.value {
            case .binary(let data):
                kind = .binary(data.toBase64() ?? "")
                
            case .integer(let number):
                kind = .integer(number)
                
            case .boolean(let flag):
                kind = .boolean(flag)
                
            case .string(let str):
                kind = .string(str)
            }
            
            return TransactionSignatureV1.Structure.Data.Value.init(key: value.key, value: kind)
            
        })
    }
    
    var dataForNode: [NodeService.Query.Transaction.Data.Value] {
        return self.data.map { (value) -> NodeService.Query.Transaction.Data.Value in
            
            var kind: NodeService.Query.Transaction.Data.Value.Kind!
            
            switch value.value {
            case .binary(let data):
                kind = .binary(data.toBase64() ?? "")
                
            case .integer(let number):
                kind = .integer(number)
                
            case .boolean(let flag):
                kind = .boolean(flag)
                
            case .string(let str):
                kind = .string(str)
            }
            
            return NodeService.Query.Transaction.Data.Value(key: value.key, value: kind)
        }
    }
}
