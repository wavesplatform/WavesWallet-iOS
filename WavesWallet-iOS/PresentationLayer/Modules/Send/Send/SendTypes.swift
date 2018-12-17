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
        case moneroAddressDidGenerate(ResponseType<DTO.GatewayInfo>)
        case getAssetById(String)
        case cancelGetingAsset
        case didGetAssetBalance(DomainLayer.DTO.SmartAssetBalance?)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case didGetInfo(DTO.GatewayInfo)
            case didFailInfo(NetworkError)
            case aliasDidFinishCheckValidation(Bool)
            case didGetWavesAsset(DomainLayer.DTO.SmartAssetBalance)
            case didGenerateMoneroAddress(DTO.GatewayInfo)
            case didFailGenerateMoneroAddress(NetworkError)
            case didGetAssetBalance(DomainLayer.DTO.SmartAssetBalance?)
        }
        
        var isNeedLoadGateWayInfo: Bool
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
    
    enum InputModel {
        
        struct ResendTransaction {
            let address: String
            let asset: DomainLayer.DTO.Asset
            let amount: Money
        }
        
        case empty
        case selectedAsset(DomainLayer.DTO.SmartAssetBalance)
        case resendTransaction(ResendTransaction)
  
        var selectedAsset: DomainLayer.DTO.SmartAssetBalance? {
            switch self {
            case .selectedAsset(let asset):
                return asset
            default:
                return nil
            }
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

extension Send.State: Equatable {
    
    static func == (lhs: Send.State, rhs: Send.State) -> Bool {
        return lhs.isNeedLoadGateWayInfo == rhs.isNeedLoadGateWayInfo &&
                lhs.isNeedValidateAliase == rhs.isNeedValidateAliase &&
                lhs.isNeedGenerateMoneroAddress == rhs.isNeedGenerateMoneroAddress &&
                lhs.recipient == rhs.recipient &&
                lhs.moneroPaymentID == rhs.moneroPaymentID &&
                lhs.selectedAsset?.assetId == rhs.selectedAsset?.assetId &&
                lhs.scanningAssetID == rhs.scanningAssetID
    }
}

