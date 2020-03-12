//
//  PayoutsHistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import WavesSDK

struct PayoutsHistoryState {
    
    enum UI {
        case showLoadingIndicator
        case hideLoadingIndicator
        case loadingError(String)
        case dataLoadded([PayoutTransactionVM])
    }
    
    enum Core {
        case isLoading
        case loadingError(Error)
        case dataLoaded(DataService.Response<[DataService.DTO.MassTransferTransaction]>)
    }
    
    var ui: UI
    var core: Core
}

extension PayoutsHistoryState.UI {
    struct PayoutTransactionVM {
        let title: String
        let details: String
        let transactionValue: BalanceLabel.Model
        let dateText: String
    }
}

enum PayoutsHistoryEvents {
    case performLoading
    case pullToRefresh
    
    case dataLoaded(DataService.Response<[DataService.DTO.MassTransferTransaction]>)
    case loadingError
}
