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
        case didGetGatewayInfo(Response<DTO.GatewayInfo>)
        case didChangeRecipient(String)
        case didChangeAsset(DomainLayer.DTO.AssetBalance, isLoadInfo: Bool)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case didGetInfo(DTO.GatewayInfo)
            case didFailInfo(String)
        }
        
        var isNeedLoadInfo: Bool
        var action: Action
        var recipient: String = ""
        var selectedAsset: DomainLayer.DTO.AssetBalance?
    }
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
}

extension Send.State: Equatable {
    
    static func == (lhs: Send.State, rhs: Send.State) -> Bool {
        return lhs.isNeedLoadInfo == rhs.isNeedLoadInfo &&
                lhs.recipient == rhs.recipient &&
                lhs.selectedAsset?.assetId == rhs.selectedAsset?.assetId
        
    }
}

