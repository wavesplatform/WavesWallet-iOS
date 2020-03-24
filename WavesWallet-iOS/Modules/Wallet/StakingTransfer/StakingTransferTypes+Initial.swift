//
//  StakingTransferTypes+Initial.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 23.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer

extension StakingTransfer.State.UI {
    
    static func initialState(kind: StakingTransfer.DTO.Kind) -> StakingTransfer.State.UI {
        
        switch kind {
        case .card:
            return initialStateCard()
            
        case .deposit:
            return initialStateDeposit()
            
        case .withdraw:
            return initialStateWithdraw()
        }
    }
    
    
    static func initialStateCard() -> StakingTransfer.State.UI {
                        
        let title = Localizable.Waves.Staking.Transfer.Card.title
        
        let balance = StakingTransfer.ViewModel.Section(rows: [.skeletonBalance])
        
        return StakingTransfer.State.UI(sections: [balance],
                                        title: title,
                                        action: .update(nil, error: nil))
    }

    static func initialStateDeposit() -> StakingTransfer.State.UI {

        let title = Localizable.Waves.Staking.Transfer.Deposit.title

        let balance = StakingTransfer.ViewModel.Section(rows: [.skeletonBalance])
        
        return StakingTransfer.State.UI(sections: [balance],
                                        title: title,
                                        action: .update(nil, error: nil))
    }

    static func initialStateWithdraw() -> StakingTransfer.State.UI {

        let title = Localizable.Waves.Staking.Transfer.Withdraw.title

        let balance = StakingTransfer.ViewModel.Section(rows: [.skeletonBalance])
        
        return StakingTransfer.State.UI(sections: [balance],
                                        title: title,
                                        action: .update(nil, error: nil))
    }
}

