//
//  StakingTransferSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import Extensions

final class StakingTransferSystem: System<StakingTransfer.State, StakingTransfer.Event> {
    
    override func initialState() -> State! {

        let core: State.Core = .init(kind: .card)
        let ui: State.UI = .init(sections: [],
                                 action: .none)
        
        return State(ui: ui,
                     core: core)
    }

    override func internalFeedbacks() -> [Feedback] {
        return []
        
    }

    override func reduce(event: Event, state: inout State) {
        
//        switch event {
//
//        }
    }
}

