//
//  NewWalletTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/30/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

enum NewWalletTypes {}

extension NewWalletTypes {
    enum ViewModel {}
    enum DTO {}
}

extension NewWalletTypes.ViewModel {
    enum Kind: Int {
        case assets
        case leasing
        
        var title: String {
            switch self {
            case .assets:
                return Localizable.Waves.Wallet.Segmentedcontrol.assets
                
            case .leasing:
                return Localizable.Waves.Wallet.Segmentedcontrol.leasing
            }
        }
    }
}

extension NewWalletTypes.ViewModel {
    struct Section: Mutating {
        var items: [Row]
        var kind: Kind
    }
    
    enum Row {
        case emptyTopContent
        case emptySegmentedControl
        case hidden
        case asset(DomainLayer.DTO.SmartAssetBalance)
        case assetSkeleton
        case balanceSkeleton
        case historySkeleton
        case balance(WalletTypes.DTO.Leasing.Balance)
        case leasingTransaction(DomainLayer.DTO.SmartTransaction)
        case allHistory
        case quickNote
    }
}
