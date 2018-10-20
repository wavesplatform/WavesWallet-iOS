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

    enum Event {
        case didChangeRecipient(String)
        case didSelectAsset(DomainLayer.DTO.AssetBalance, loadGatewayInfo: Bool)
        case getGatewayInfo
        case didGetGatewayInfo(Response<DTO.GatewayInfo>)
        case checkValidationAlias
        case validationAliasDidComplete(Bool)
        case didGetWavesAsset(DomainLayer.DTO.AssetBalance)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case didGetInfo(DTO.GatewayInfo)
            case didFailInfo(String)
            case aliasDidFinishCheckValidation(Bool)
            case didGetWavesAsset(DomainLayer.DTO.AssetBalance)
        }
        
        var isNeedLoadInfo: Bool
        var isNeedValidateAliase: Bool
        var isNeedLoadWaves: Bool
        var action: Action
        var recipient: String = ""
        var selectedAsset: DomainLayer.DTO.AssetBalance?
    }
}

extension Send.ViewModel {
    static var minimumAliasLength = 4
    static var maximumAliasLength = 30
    
    //TODO: Need change to real maximum length
    static var maximumDescriptionLength = 50
}

extension Send.DTO {
    
    struct Order {
        let asset: DomainLayer.DTO.Asset
        let amount: Money
        let recipient: String
    }
    
    struct GatewayInfo {
        let assetName: String
        let assetShortName: String
        let minAmount: Money
        let maxAmount: Money
        let fee: Money
    }
    
//    struct Transaction {
//        let type: Int = 4
//        let id;
//        "id" ~~> Base58.encode(id),
//        "sender" ~~> senderPublicKey.address,
//        "senderPublicKey" ~~> Base58.encode(senderPublicKey.publicKey),
//        "fee" ~~> fee.amount,
//        "timestamp" ~~> timestamp,
//        "signature" ~~> Base58.encode(getSignature()),
//        "recipient" ~~> recipient,
//        "assetId" ~~> asset,
//        "amount" ~~> amount.amount,
//        "feeAsset" ~~> feeAsset,
//        "attachment" ~
//    }
}

extension Send.State: Equatable {
    
    static func == (lhs: Send.State, rhs: Send.State) -> Bool {
        return lhs.isNeedLoadInfo == rhs.isNeedLoadInfo &&
                lhs.isNeedValidateAliase == rhs.isNeedValidateAliase &&
                lhs.recipient == rhs.recipient &&
                lhs.selectedAsset?.assetId == rhs.selectedAsset?.assetId
    }
}

