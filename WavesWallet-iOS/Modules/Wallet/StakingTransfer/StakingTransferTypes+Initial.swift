//
//  StakingTransferTypes+Initial.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 23.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation

extension StakingTransfer.State.UI {
    
    static func initialState(kind: StakingTransfer.DTO.Kind) -> StakingTransfer.State.UI {
        
        switch kind {
        case .card:
            return initialStateCard()
            
        case .deposit:
            return initialStateCard()
            
        case .withdraw:
            return initialStateCard()
        }
    }
    
    static func initialStateCard() -> StakingTransfer.State.UI {
        return StakingTransfer.State.UI(sections: [],
                                        action: .reload)
    }
}
