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

    enum Event {
        case readyView
        case tapFavoriteButton(IndexPath)
        case dragAsset(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
        case setAssets([DTO.Asset])
    }

    struct State {
        enum Status {
            case position
            case visibility
        }

        var status: Status
        var sections: [WalletSort.ViewModel.Section]
    }
}

extension WalletSort.ViewModel {
    struct Section {
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
    struct Asset: Hashable {
        let id: String
        let name: String
        let isLock: Bool
        let isMyAsset: Bool
        let isFavorite: Bool
        let isFiat: Bool
        let sortLevel: Float
    }
}
