//
//  WalletSortTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum WalletSort {
    enum DTO {}
    enum ViewModel {}

    enum Direction {
        case top
        case down
    }

    enum Event {
        case readyView
        case setStatus(State.Status)
        case tapFavoriteButton(IndexPath)
        case tapHidden(IndexPath)
        case dragAsset(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
        case setAssets([DTO.Asset])
    }

    struct State: Mutating {

        enum Action {
            case none
            case refresh
        }

        enum Status {
            case position
            case visibility
        }

        var isNeedRefreshing: Bool
        var status: Status
        var sections: [WalletSort.ViewModel.Section]
        var action: Action
    }
}

extension WalletSort.ViewModel {
    struct Section: Mutating {
        enum Kind {
            case favorities
            case all
        }

        let kind: Kind
        var items: [Row]
    }

    enum Row {        
        case favorityAsset(WalletSort.DTO.Asset)
        case asset(WalletSort.DTO.Asset)
    }
}

extension WalletSort.DTO {
    struct Asset: Mutating {
        let id: String
        let name: String
        let isLock: Bool
        let isMyWavesToken: Bool
        var isFavorite: Bool
        let isGateway: Bool
        var isHidden: Bool
        var sortLevel: Float
        let icon: String
    }
}
