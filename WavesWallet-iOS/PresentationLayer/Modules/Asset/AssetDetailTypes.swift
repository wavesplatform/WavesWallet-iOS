//
//  AssetTypes.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 14.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum AssetDetailTypes {}

extension AssetDetailTypes {
    enum ViewModel {}
    enum DTO {}
}

extension AssetDetailTypes {

    struct State: Mutating {

        enum TransactionStatus {
            case none
            case empty
            case loading
            case transaction([DomainLayer.DTO.SmartTransaction])

            var isLoading: Bool {
                switch self {
                case .loading:
                    return true
                default:
                    return false
                }
            }
        }

        var assets: [DTO.Asset]
        var transactionStatus: TransactionStatus
        var displayState: DisplayState
    }

    enum Event {
        case readyView
        case changedAsset(id: String)
        case setTransactions([DomainLayer.DTO.SmartTransaction])
        case setAssets([DTO.Asset])
        case refreshing
        case tapFavorite(on: Bool)
        case tapSend
        case tapReceive
        case tapExchange
        case tapTransaction(DomainLayer.DTO.SmartTransaction)
        case tapHistory
        case showReceive(DomainLayer.DTO.SmartAssetBalance)
        case showSend(DomainLayer.DTO.SmartAssetBalance)
        case tapBurn(asset: DomainLayer.DTO.SmartAssetBalance, delegate: TokenBurnTransactionDelegate?)
    }

    struct DisplayState: DataSourceProtocol, Mutating {

        enum Action {
            case none
            case refresh            
            case changedCurrentAsset
            case changedFavorite
        }

        var isAppeared: Bool
        var isRefreshing: Bool
        var isFavorite: Bool
        var isDisabledFavoriteButton: Bool
        var isUserInteractionEnabled: Bool

        var currentAsset: DTO.Asset.Info
        var assets: [DTO.Asset.Info]
        var sections: [ViewModel.Section] = []
        var action: Action
    }
}

extension AssetDetailTypes.ViewModel {

    struct Section: SectionProtocol {

        enum Kind {
            case none
            case title(String)
            case skeletonTitle
        }
        
        var kind: Kind
        var rows: [AssetDetailTypes.ViewModel.Row]
    }

    enum Row {
        case balanceSkeleton
        case balance(AssetDetailTypes.DTO.Asset.Balance)
        case spamBalance(AssetDetailTypes.DTO.Asset.Balance)
        case viewHistory
        case viewHistoryDisabled
        case viewHistorySkeleton
        case lastTransactions([DomainLayer.DTO.SmartTransaction])
        case transactionSkeleton
        case assetInfo(AssetDetailTypes.DTO.Asset.Info)
        case tokenBurn(AssetDetailTypes.DTO.Asset.Info)
    }
}

extension AssetDetailTypes.DTO {

    struct Asset {

        struct Info {
            let id: String
            let issuer: String
            let name: String
            let description: String
            let issueDate: Date
            let isReusable: Bool
            let isMyWavesToken: Bool
            let isWavesToken: Bool
            let isWaves: Bool
            var isFavorite: Bool
            let isFiat: Bool
            let isSpam: Bool
            let isGateway: Bool
            let sortLevel: Float
            let icon: DomainLayer.DTO.Asset.Icon
            var assetBalance: DomainLayer.DTO.SmartAssetBalance
        }

        struct Balance: Codable {
            let totalMoney: Money
            let avaliableMoney: Money
            let leasedMoney: Money
            let inOrderMoney: Money
            let isFiat: Bool
        }

        var info: Info
        let balance: Balance
    }
}

extension AssetDetailTypes.ViewModel.Section {
    
    var assetBalance: DomainLayer.DTO.SmartAssetBalance? {
        if let row = rows.first(where: {$0.asset != nil}) {
            if let asset = row.asset {
                return asset.assetBalance
            }
        }
        return nil
    }
}
extension AssetDetailTypes.ViewModel.Row {
    
    var asset: AssetDetailTypes.DTO.Asset.Info? {
        switch self {
        case .assetInfo(let info):
            return info
        default:
            return nil
        }
    }
}
