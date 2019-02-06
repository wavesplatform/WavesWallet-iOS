//
//  SendFeeTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

private enum Constants {
    static let wavesMinFee: Decimal = 0.001
}

enum SendFee {
    enum DTO {}
    enum ViewModel {}
    
    enum Event {
        case didGetAssets([DomainLayer.DTO.SmartAssetBalance])
        case handleError(NetworkError)
    }
    
    struct State: Mutating {

        enum Action {
            case none
            case update
            case handleError(NetworkError)
        }
        
        let feeAssetID: String
        let wavesFee: Money
        var action: Action
        var isNeedLoadAssets: Bool
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
    
    static func calculateSponsoredFee(by asset: DomainLayer.DTO.Asset, wavesFee: Money) -> Money {
        
        let sponsorFee = Money(asset.minSponsoredFee, asset.precision).decimalValue
        let value = (wavesFee.decimalValue / Constants.wavesMinFee) * sponsorFee
        return Money(value: value, asset.precision)
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
