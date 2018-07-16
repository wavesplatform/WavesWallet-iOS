//
//  WalletTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources

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
        case hidden
        case asset(Asset)
        //        case leasing()
    }

    struct Section: Hashable {        
        var header: String?
        var items: [Row]
        var isExpanded: Bool
    }
}

extension WalletTypes.ViewModel.Section: SectionModelType {

    init(original: WalletTypes.ViewModel.Section, items: [WalletTypes.ViewModel.Row]) {
        self = original
        self.items = items
    }    
}
