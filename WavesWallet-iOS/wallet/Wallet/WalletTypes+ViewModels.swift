//
//  WalletTypes+ViewModels.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 16/07/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources

// MARK: ViewModel for UITableView
extension WalletTypes.ViewModel {
    enum Row: Hashable {
        case hidden
        case assetSkeleton
        case balanceSkeleton
        case historySkeleton
        case asset(WalletTypes.DTO.Asset)
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

extension WalletTypes.ViewModel.Section {
//    var header: String?
//    var items: [Row]
//    var isExpanded: Bool
    static func mapFrom(assets: [WalletTypes.DTO.Asset]) -> [WalletTypes.ViewModel.Section] {

        var generalItems = assets
            .filter { $0.state == .general || $0.state == .favorite }
            .map { WalletTypes.ViewModel.Row.asset($0) }
        var generalSection: WalletTypes.ViewModel.Section = .init(header: nil,
                                                                  items: generalItems,
                                                                  isExpanded: true)

//        var spam

        return [generalSection]
    }

//    struct Asset: Hashable {
//        enum Kind: Hashable {
//            case gateway
//            case fiatMoney
//            case wavesToken
//        }
//
//        enum State: Hashable {
//
//            case general
//            case favorite
//            case hidden
//            case spam
//        }
//
//        let id: String
//        let name: String
//        let balance: Money
//        let fiatBalance: Money
//        //        let king: Kind
//        let state: State
//        let level: Float
//    }
}
