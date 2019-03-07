//
//  TransactionCardType.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

enum TransactionCard {

    struct State {

        struct UI {
            var sections: [Section]
        }

        struct Core {
            let transaction: DomainLayer.DTO.SmartTransaction
        }

        enum Action {
            case get
        }

        var ui: UI
        var core: Core?
    }

    enum Event {
        case viewDidAppear
        case showAllRecipients
    }

    struct Section: SectionProtocol {
        var rows: [Row]
    }

    enum Row {
        case head
        case address
        case keyValue
        case dottedLine
        case actions
        case description
        case exchange
        case assetDetail
        case showAll
    }
}
