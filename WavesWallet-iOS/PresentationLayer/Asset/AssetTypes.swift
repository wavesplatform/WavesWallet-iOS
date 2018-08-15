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

    struct DisplayState: StateDisplayCollection, Mutating {

        enum AnimateType {
            case none
            case refresh
        }
        

        var currentAsset: AssetTypes.DTO.Asset
        var assets: AssetTypes.DTO.Asset = [AssetTypes.DTO.Asset]
        var sections: [AssetTypes.ViewModel.Section] = []
        var isAppeared: Bool
        var isRefreshing: Bool
        var isFavorite: Bool
    }
}

extension AssetTypes.ViewModel {

    struct Section: SectionCollection {
        var rows: [AssetTypes.ViewModel.Row]
    }

    enum Row {
        case balanceSkeleton
        case balance(AssetTypes.DTO.Asset.Balance)
        case viewHistory
        case lastTransactions([AssetTypes.DTO.Asset.Transaction])
        case transactionSkeleton
        case assetInfo(AssetTypes.DTO.Asset.Info)
    }
}

extension AssetTypes.DTO {

    struct Asset {

        struct Info {
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

        struct Balance {
            let totalMoney: Money
            let avaliableMoney: Money
            let leasedMoney: Money
            let leasedInMoney: Money
        }

        struct Transaction {

        }

        let info: Info
        let balance: Balance
        let transactions: [Transaction]
    }
}
