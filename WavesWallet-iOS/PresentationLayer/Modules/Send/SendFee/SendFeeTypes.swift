//
//  SendFeeTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

enum SendFee {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case didGetInfo([DomainLayer.DTO.SmartAssetBalance], Money)
        case handleError(NetworkError)
    }
    
    struct State: Mutating {

        enum Action {
            case none
            case update
            case handleError(NetworkError)
        }
        
        let feeAssetID: String
        var action: Action
        var isNeedLoadInfo: Bool
        var sections: [ViewModel.Section]
    }
}

extension SendFee.DTO {
    
    struct SponsoredAsset {
        let asset: DomainLayer.DTO.Asset
        let fee: Money
        let isChecked: Bool
        let isActive: Bool
    }
}

extension SendFee.ViewModel {
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row {
        case header
        case asset(SendFee.DTO.SponsoredAsset)
    }
}

extension SendFee.ViewModel.Row {
    
    var asset: SendFee.DTO.SponsoredAsset? {
        
        switch self {
        case .asset(let asset):
            return asset
        default:
            return nil
        }
    }
}
