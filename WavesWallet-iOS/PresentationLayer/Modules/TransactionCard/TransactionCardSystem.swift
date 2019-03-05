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

final class TransactionCardSystem: System {

    func internalSideEffects() -> [Feedback] {
        return []
    }

    var initialState: TransactionCard.State {
        return TransactionCard.State(sections: [])
    }

    func reduce(event: TransactionCard.Event, state: inout TransactionCard.State) {
        
    }
}
//
//private final class TransactionCardCoreSystem: TransactionCardSystemProtocol {
//
//    func internalSideEffects() -> [Feedback] {
//        return []
//    }
//
//    var initialState: TransactionCard.State {
//        return TransactionCard.State(sections: [])
//    }
//
//    func reduce(event: TransactionCard.Event, state: inout TransactionCard.State) {
//
//    }
//}
