//
//  PaymentHistorySystem.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import Foundation
import RxCocoa
import RxSwift

final class PayoutsHistorySystem: System<PayoutsHistoryState, PayoutsHistoryEvents> {
    
    //AuthorizationUseCase.lastWalletLoggedIn
    //
    
    override func internalFeedbacks() -> [(Driver<PayoutsHistoryState>) -> Signal<PayoutsHistoryEvents>] {
        []
    }
    
    override func initialState() -> PayoutsHistoryState! {
        PayoutsHistoryState(ui: .showLoadingIndicator, core: .init())
    }
    
    override func reduce(event: PayoutsHistoryEvents, state: inout PayoutsHistoryState) {
        
    }
}
