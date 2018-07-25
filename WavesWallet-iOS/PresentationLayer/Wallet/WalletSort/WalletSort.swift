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
        case dragAsset(IndexPath)
    }

    struct State {
        enum Status {
            case position
            case visibility
        }

        let sections: [Section]
    }

    struct Section {
        enum Kind {
            case favorities
            case sorted
        }

        let kind: Kind
        let items: [Row]
    }

    enum Row {
        case separator
        case favorityAsset(Asset)
        case asset(Asset)
    }
}
