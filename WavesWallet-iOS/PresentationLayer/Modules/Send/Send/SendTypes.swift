//
//  SendTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/17/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum Send {
    enum DTO {}
    enum ViewModel {}

    enum TransactionStatus {
        case success
        case error(NetworkError)
    }
    
    enum Event {
        case didChangeRecipient(String)
        case didChangeMoneroPaymentID(String)
        case didSelectAsset(DomainLayer.DTO.SmartAssetBalance, loadGatewayInfo: Bool)
        case getGatewayInfo
        case didGetGatewayInfo(ResponseType<DTO.GatewayInfo>)
        case checkValidationAlias
        case validationAliasDidComplete(Bool)
        case didGetWavesAsset(DomainLayer.DTO.SmartAssetBalance)
        case moneroAddressDidGenerate(ResponseType<String>)
        case getAssetById(String)
        case didGetAssetBalance(DomainLayer.DTO.SmartAssetBalance?)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case didGetInfo(DTO.GatewayInfo)
            case didFailInfo(NetworkError)
            case aliasDidFinishCheckValidation(Bool)
            case didGetWavesAsset(DomainLayer.DTO.SmartAssetBalance)
            case didGenerateMoneroAddress(String)
            case didFailGenerateMoneroAddress(NetworkError)
            case didGetAssetBalance(DomainLayer.DTO.SmartAssetBalance?)
        }
        
        var isNeedLoadInfo: Bool
        var isNeedValidateAliase: Bool
        var isNeedLoadWaves: Bool
        var isNeedGenerateMoneroAddress: Bool
        var action: Action
        var recipient: String = ""
        var moneroPaymentID: String = ""
        var selectedAsset: DomainLayer.DTO.SmartAssetBalance?
        var scanningAssetID: String?
    }
}

extension Send.ViewModel {
    static var minimumAliasLength = 4
    static var maximumAliasLength = 30
    static var maximumDescriptionLength = 140
}

extension Send.DTO {
    
    struct Transaction {
        private let senderPrivateKey: PrivateKeyAccount
        private let isAlias: Bool
        private let aliasVersion: UInt8 = 2
        
        let type: UInt8 = 4
        let version: UInt8 = 2
        let senderPublicKey: PublicKeyAccount
        let fee: Money
        let timestamp: Int64
        let recipient: String
        let assetId: String
        let feeAssetId: String = ""
        let feeAsset: String = ""
        let amount: Money
        let attachment: String
        
        init(senderPublicKey: PublicKeyAccount, senderPrivateKey: PrivateKeyAccount, fee: Money, recipient: String, assetId: String, amount: Money, attachment: String, isAlias: Bool) {
            
            self.senderPublicKey = senderPublicKey
            self.senderPrivateKey = senderPrivateKey
            self.isAlias = isAlias
            self.fee = fee
            self.recipient = isAlias ? Environments.current.aliasScheme + recipient : recipient
            self.assetId = assetId
            self.amount = amount
            self.attachment = attachment
            self.timestamp = Int64(Date().millisecondsSince1970)
        }
    }
    
    struct GatewayInfo {
        let assetName: String
        let assetShortName: String
        let minAmount: Money
        let maxAmount: Money
        let fee: Money
        let address: String
        let attachment: String
    }
}

extension Send.DTO.Transaction {
    
    var proofs: [String] {
        return [Base58.encode(Hash.sign(toSign, senderPrivateKey.privateKey))]
    }

    private var recipientBytes: [UInt8] {
        if isAlias {
            let alias = (recipient as NSString).substring(from: Environments.current.aliasScheme.count)
            return [aliasVersion] +
                Environments.current.scheme.bytes +
                alias.arrayWithSize()
        }
        return Base58.decode(recipient)
    }
    
    private var toSign: [UInt8] {
        
        let assetIdBytes = assetId.isEmpty ? [UInt8(0)] :  ([UInt8(1)] + Base58.decode(assetId))
        let feeAssetIdBytes = [UInt8(0)]
        let s1 = [type] + [version] + senderPublicKey.publicKey
        let s2 = assetIdBytes + feeAssetIdBytes + toByteArray(timestamp) + toByteArray(amount.amount) + toByteArray(fee.amount)
        let s3 = recipientBytes + attachment.arrayWithSize()
        return s1 + s2 + s3
    }
}

extension Send.State: Equatable {
    
    static func == (lhs: Send.State, rhs: Send.State) -> Bool {
        return lhs.isNeedLoadInfo == rhs.isNeedLoadInfo &&
                lhs.isNeedValidateAliase == rhs.isNeedValidateAliase &&
                lhs.isNeedGenerateMoneroAddress == rhs.isNeedGenerateMoneroAddress &&
                lhs.recipient == rhs.recipient &&
                lhs.moneroPaymentID == rhs.moneroPaymentID &&
                lhs.selectedAsset?.assetId == rhs.selectedAsset?.assetId &&
                lhs.scanningAssetID == rhs.scanningAssetID
    }
}

