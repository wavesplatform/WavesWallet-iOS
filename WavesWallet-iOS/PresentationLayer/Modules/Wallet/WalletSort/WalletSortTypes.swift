//
//  NewWalletSortTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/17/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

enum WalletSort {
    enum DTO {}
    enum ViewModel {}
  
    enum Event {
        case readyView
        case setStatus(Status)
        case setFavoriteAt(IndexPath)
        case setHiddenAt(IndexPath)
        case moveAsset(from: IndexPath, to: IndexPath)
    }
    
    enum Status {
        case position
        case visibility
    }
    
    struct State: Mutating {
       
        enum Action {
            case none
            case refresh
            case refreshWithAnimation(movedRowAt: IndexPath)
            case move(at: IndexPath, to: IndexPath, delete: IndexPath?, insert: IndexPath?)
            case updateMoveAction(insertAt: IndexPath?, deleteAt: IndexPath?, movedRowAt: IndexPath)
        }
        
        var assets: [WalletSort.DTO.Asset]
        var status: Status
        var sections: [ViewModel.Section]
        var action: Action
    }
}

extension WalletSort.ViewModel {
    
    struct Section: Mutating {
        enum Kind {
            case top
            case favorities
            case list
            case hidden
        }
        
        let kind: Kind
        var items: [Row]
    }
    
    enum AssetType {
        case favourite
        case list
        case hidden
    }
    
    enum Row {
        case top
        case favorityAsset(WalletSort.DTO.Asset)
        case list(WalletSort.DTO.Asset)
        case hidden(WalletSort.DTO.Asset)
        case emptyAssets(WalletSort.ViewModel.AssetType)
        case separator(isShowHiddenTitle: Bool)
    }
}


extension WalletSort.DTO {
    
    struct Asset: Mutating {
        let id: String
        let name: String
        let isMyWavesToken: Bool
        var isFavorite: Bool
        let isGateway: Bool
        var isHidden: Bool
        var sortLevel: Float
        let icon: DomainLayer.DTO.Asset.Icon
        let isSponsored: Bool
        let hasScript: Bool
    }
}

extension WalletSort.ViewModel.Row {
    
    var asset: WalletSort.DTO.Asset? {
        switch self {
        case .favorityAsset(let asset):
            return asset
            
        case .list(let asset):
            return asset
            
        case .hidden(let asset):
            return asset
            
        default:
            return nil
        }
    }
    
    var isMovable: Bool {
        switch self {
        case .favorityAsset:
            return true
            
        case .list:
            return true
            
        case .hidden:
            return true
            
        default:
            return false
        }
    }
}

