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

        let section = Types.Section(rows: [.head, .address])

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
