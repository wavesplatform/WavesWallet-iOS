//
//  PayoutsHistoryTypes.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

struct PayoutsHistoryState {
    
    enum UI {
        case showLoadingIndicator
        case hideLoadingIndicator
        case loadingError(String)
        case dataLoadded([PayoutTransactionVM])
    }
    
    struct Core {
        
    }
    
    let ui: UI
    let core: Core
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
    
}
