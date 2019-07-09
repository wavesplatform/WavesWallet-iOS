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
                                specifications: TransactionSenderSpecifications) -> NodeService.Query.Broadcast? {
        
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
                                                proofs: [String]) -> NodeService.Query.Broadcast {
        
        switch self {
            
        case .burn(let model):
            
            return .burn(NodeService.Query.Broadcast.Burn(version: self.version,
                                                          type: self.type.rawValue,
                                                          scheme: environment.scheme,
                                                          fee: model.fee,
                                                          assetId: model.assetID,
                                                          quantity: model.quantity,
                                                          timestamp: timestamp,
                                                          senderPublicKey: publicKey,
                                                          proofs: proofs))
            
        case .createAlias(let model):
            
            return .createAlias(NodeService.Query.Broadcast.Alias(version: self.version,
                                                                  name: model.alias,
                                                                  fee: model.fee,
                                                                  timestamp: timestamp,
                                                                  type: self.type.rawValue,
                                                                  senderPublicKey: publicKey,
                                                                  proofs: proofs))
        case .lease(let model):
            
            var recipient = ""
            if model.recipient.count <= WavesSDKConstants.aliasNameMaxLimitSymbols {
                recipient = environment.aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            return .startLease(NodeService.Query.Broadcast.Lease(version: self.version,
                                                                 scheme: environment.scheme,
                                                                 fee: model.fee,
                                                                 recipient: recipient,
                                                                 amount: model.amount,
                                                                 timestamp: timestamp,
                                                                 type: self.type.rawValue,
                                                                 senderPublicKey: publicKey,
                                                                 proofs: proofs))
        case .cancelLease(let model):
            
            return .cancelLease(NodeService.Query.Broadcast.LeaseCancel(version: self.version,
                                                                        scheme: environment.scheme,
                                                                        fee: model.fee,
                                                                        leaseId: model.leaseId,
                                                                        timestamp: timestamp,
                                                                        type: self.type.rawValue,
                                                                        senderPublicKey: publicKey,
                                                                        proofs: proofs))
            
        case .data(let model):
            
            return .data(NodeService.Query.Broadcast.Data.init(type: self.type.rawValue,
                                                               version: self.version,
                                                               fee: model.fee,
                                                               timestamp: timestamp,
                                                               senderPublicKey: publicKey,
                                                               proofs: proofs,
                                                               data: model.dataForNode))
            
        case .send(let model):
            
            var recipient = ""
            if model.recipient.count <= WavesSDKConstants.aliasNameMaxLimitSymbols {
                recipient = environment.aliasScheme + model.recipient
            } else {
                recipient = model.recipient
            }
            
            return .send(NodeService.Query.Broadcast.Send(type: self.type.rawValue,
                                                          version: self.version,
                                                          recipient: recipient,
                                                          assetId: model.assetId,
                                                          amount: model.amount,
                                                          fee: model.fee,
                                                          attachment: Base58Encoder.encode(Array(model.attachment.utf8)),
                                                          feeAssetId: model.getFeeAssetID,
                                                          feeAsset: model.getFeeAssetID,
                                                          timestamp: timestamp,
                                                          senderPublicKey: publicKey,
                                                          proofs: proofs))
        }
        
    }
    
    private func signature(timestamp: Int64, scheme: String, publicKey: [UInt8]) -> [UInt8] {
        
        switch self {
            
        case .data(let model):
            
            let bytes = TransactionSignatureV2.data(.init(fee: model.fee,
                                                          data: model.dataForSignature,
                                                          scheme: scheme,
                                                          senderPublicKey: Base58Encoder.encode(publicKey),
                                                          timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .burn(let model):
            
            let bytes = TransactionSignatureV2.burn(.init(assetID: model.assetID,
                                                          quantity: model.quantity,
                                                          fee: model.fee,
                                                          scheme: scheme,
                                                          senderPublicKey: Base58Encoder.encode(publicKey),
                                                          timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .cancelLease(let model):
            
            let bytes = TransactionSignatureV2.cancelLease(.init(leaseId: model.leaseId,
                                                                 fee: model.fee,
                                                                 scheme: scheme,
                                                                 senderPublicKey: Base58Encoder.encode(publicKey),
                                                                 timestamp: timestamp)).bytesStructure
            
            return bytes
            
            
        case .createAlias(let model):
            
            let bytes = TransactionSignatureV2.createAlias(.init(alias: model.alias,
                                                                 fee: model.fee,
                                                                 scheme: scheme,
                                                                 senderPublicKey: Base58Encoder.encode(publicKey),
                                                                 timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .lease(let model):
            
            let bytes = TransactionSignatureV2.startLease(.init(recipient: model.recipient,
                                                                amount: model.amount,
                                                                fee: model.fee,
                                                                scheme: scheme,
                                                                senderPublicKey: Base58Encoder.encode(publicKey),
                                                                timestamp: timestamp)).bytesStructure
            
            return bytes
            
        case .send(let model):
            
            let bytes = TransactionSignatureV2.transfer(.init(senderPublicKey: Base58Encoder.encode(publicKey),
                                                              recipient: model.recipient,
                                                              assetId: model.assetId,
                                                              amount: model.amount,
                                                              fee: model.fee,
                                                              attachment: model.attachment,
                                                              feeAssetID: model.feeAssetID,
                                                              scheme: scheme,
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
    
    var dataForSignature: [TransactionSignatureV2.Structure.Data.Value] {
        return self.data.map({ (value) -> TransactionSignatureV2.Structure.Data.Value in
            
            var kind: TransactionSignatureV2.Structure.Data.Value.Kind!
            
            switch value.value {
            case .binary(let data):
                kind = .binary(data)
                
            case .integer(let number):
                kind = .integer(number)
                
            case .boolean(let flag):
                kind = .boolean(flag)
                
            case .string(let str):
                kind = .string(str)
            }
            
            return TransactionSignatureV2.Structure.Data.Value.init(key: value.key, value: kind)
            
        })
    }
    
    var dataForNode: [NodeService.Query.Broadcast.Data.Value] {
        return self.data.map { (value) -> NodeService.Query.Broadcast.Data.Value in
            
            var kind: NodeService.Query.Broadcast.Data.Value.Kind!
            
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
            
            return NodeService.Query.Broadcast.Data.Value.init(key: value.key, value: kind)
        }
    }
}
