//
//  AssetTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 14.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AssetTypes {}

extension AssetTypes {
    enum ViewModel {}
    enum DTO {}
}

extension AssetTypes {

    struct State: Mutating {

        enum EventOutput {

        }

        var event: EventOutput?
        var assets: [Asset]
        var displayState: DisplayState
    }

    enum Event {
        case readyView
        case changedAsset(id: String)
        case setAssets([AssetTypes.DTO.Asset])
        case refreshing
        case tapFavorite(on: Bool)
        case tapSend
        case tapReceive
        case tapExchange
        case tapTransaction
        case tapHistory
    }

    struct DisplayState: StateDisplayBase, Mutating {

        enum Action {
            case none
            case refresh
        }

        enum TransactionStatus {
            case empty
            case loading
            case transaction([AssetTypes.DTO.Transaction])
        }

        var isAppeared: Bool
        var isRefreshing: Bool
        var isFavorite: Bool

        var currentAsset: AssetTypes.DTO.Asset.Info
        var assets: [AssetTypes.DTO.Asset.Info]
        var sections: [AssetTypes.ViewModel.Section] = []
    }
}

extension AssetTypes.ViewModel {

    struct Section: SectionBase {

        enum Kind {
            case none
            case title(String)
            case skeletonTitle
        }
        
        var kind: Kind
        var rows: [AssetTypes.ViewModel.Row]
    }

    enum Row {
        case balanceSkeleton
        case balance(AssetTypes.DTO.Asset.Balance)
        case viewHistory
        case viewHistorySkeleton
        case lastTransactions([AssetTypes.DTO.Transaction])
        case transactionSkeleton
        case assetInfo(AssetTypes.DTO.Asset.Info)
    }
}

extension AssetTypes.DTO {

    struct Transaction: Codable {

    }

    struct Asset: Codable {

        struct Info: Codable {
            let id: String
            let name: String
            let isMyWavesToken: Bool
            let isWaves: Bool
            let isFavorite: Bool
            let isFiat: Bool
            let isSpam: Bool
            let isGateway: Bool
            let sortLevel: Float
        }

        struct Balance: Codable {
            let totalMoney: Money
            let avaliableMoney: Money
            let leasedMoney: Money
            let leasedInMoney: Money
        }

        let info: Info
        let balance: Balance
    }
}
