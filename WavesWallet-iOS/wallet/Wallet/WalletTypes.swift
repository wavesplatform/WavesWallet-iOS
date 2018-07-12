//
//  WalletTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 05.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources
import UIKit

enum WalletTypes {}

extension WalletTypes {
    enum ViewModel {}
}

// MARK: ViewModels

extension WalletTypes.ViewModel {
    struct Asset: Hashable {
        enum Kind: Hashable {
            case gateway
            case fiatMoney
            case wavesToken
        }

        enum State: Hashable {
            case none
            case favorite
            case hidden
            case spam
        }

        let id: String
        let name: String
//        let icon: UIImage
//        let balance: Money
//        let king: Kind
//        let state: State
    }
}

// MARK: ViewModel for UITableView

extension WalletTypes.ViewModel {
    enum Row: Hashable {        
        case asset(Asset)
//        case leasing()
    }

    struct Section: Hashable {
        var id: String
        var header: String?
        var items: [Row]
        var isExpanded: Bool

        mutating func setExpanded(isExpanded: Bool) {
            self.isExpanded = isExpanded
        }
    }
}

extension WalletTypes.ViewModel.Row: IdentifiableType {
    var identity: String {
        switch self {
        case .asset(let asset):
            return asset.id
        }
    }
}

extension WalletTypes.ViewModel.Section: AnimatableSectionModelType {
    var identity: String { return id }

    init(original: WalletTypes.ViewModel.Section, items: [WalletTypes.ViewModel.Row]) {
        self = original
        self.items = items
    }
}
