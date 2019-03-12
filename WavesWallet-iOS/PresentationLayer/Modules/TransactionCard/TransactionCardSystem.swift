//
//  TransactionCardSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import RxFeedback
import RxSwift
import RxSwiftExt

private typealias Types = TransactionCard
final class TransactionCardSystem: System<TransactionCard.State, TransactionCard.Event> {

    //TODO: add transaction: DomainLayer.DTO.SmartTransaction
    override init() {
        
    }

    override func initialState() -> State! {

//        Started Leasing
//        let section = Types.Section(rows: [.general,
//                                           .address,
//                                           .keyValue,
//                                           .keyValue,
//                                           .keyValue,
//                                           .keyBalance,
//                                           .dashedLine,
//                                           .actions
//                                           ])

        // Exchange
//        let section = Types.Section(rows: [.general,
//                                           .exchange,
//                                           .keyValue,
//                                           .keyValue,
//                                           .status,
//                                           .keyBalance,
//                                           .dashedLine,
//                                           .actions
//            ])

        let section = Types.Section(rows: [.general,
                                           .exchange,
                                           .keyValue,
                                           .keyValue,
                                           .status,
                                           .keyBalance,
                                           .dashedLine,
                                           .actions
            ])

//        ,
//        .massSentRecipient,
//        .description,
//        .exchange,
//        .assetDetail,
//        .showAll

        return State(ui: .init(sections: [section]),
                     core: nil)
    }

    override func internalFeedbacks() -> [Feedback] {
        return []
    }

    override func reduce(event: Event, state: inout State) {

        switch event {
        case .viewDidAppear:
            break

        default:
            break
        }
    }
    
}
