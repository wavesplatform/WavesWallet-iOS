//
//  PayoutsHistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import WavesSDK

struct PayoutsHistoryState {
    
    struct UI {
        let state: State
        let viewModels: [PayoutTransactionVM]
        
        enum State {
            case isLoading
            case loadingError(String)
            case dataLoaded
            case loadingMore
        }
    }
    
    struct Core {
        let state: State
        let massTransferTrait: MassTransferTrait?
        
        enum State {
            case isLoading
            case loadingError(Error)
            case dataLoaded
            case loadingMore
        }
    }
    
    var ui: UI
    var core: Core
}

extension PayoutsHistoryState.Core {
    struct MassTransferTransactions {
        let isLastPage: Bool
        let lastCursor: String?
        let transactions: [DataService.DTO.MassTransferTransaction]
    }
}

extension PayoutsHistoryState {
    struct MassTransferTrait {
        let massTransferTransactions: PayoutsHistoryState.Core.MassTransferTransactions
        let walletAddress: String
        
        let assetLogo: AssetLogo.Icon?
        let precision: Int?
        let assetTicker: String?
    }
}

extension PayoutsHistoryState.MassTransferTrait {
    /// Метод возвращает новую копию 'PayoutsHistoryState.MassTransferTrait' совмещенным с текущим (мержит транзакции курсоры и буль)
    func copy(massTransferTrait: PayoutsHistoryState.MassTransferTrait) -> PayoutsHistoryState.MassTransferTrait {
        let newTransactions = massTransferTrait.massTransferTransactions.transactions
        let loadedTransactions = self.massTransferTransactions.transactions
        
        let newIsLastPage = massTransferTrait.massTransferTransactions.isLastPage
        let newLastCursor = massTransferTrait.massTransferTransactions.lastCursor
        let newTransactionsList = loadedTransactions + newTransactions
        
        let newMassTransferTransactions = PayoutsHistoryState.Core.MassTransferTransactions(isLastPage: newIsLastPage,
                                                                                            lastCursor: newLastCursor,
                                                                                            transactions: newTransactionsList)
        
        return .init(massTransferTransactions: newMassTransferTransactions,
                     walletAddress: walletAddress,
                     assetLogo: assetLogo,
                     precision: precision,
                     assetTicker: assetTicker)
    }
}

extension PayoutsHistoryState.UI {
    struct PayoutTransactionVM {
        let title: String
        let iconAsset: AssetLogo.Icon?
        let transactionValue: BalanceLabel.Model
        let dateText: String
        
        init(title: String, iconAsset: AssetLogo.Icon?, transactionValue: BalanceLabel.Model, dateText: String) {
            self.title = title
            self.iconAsset = iconAsset
            self.transactionValue = transactionValue
            self.dateText = dateText
        }
    }
}

enum PayoutsHistoryEvents {
    case performInitialLoading
    case pullToRefresh
    case loadMore
    
    case dataLoaded(PayoutsHistoryState.MassTransferTrait)
    case loadedMore(PayoutsHistoryState.MassTransferTrait)
    case loadingError(Error)
}
