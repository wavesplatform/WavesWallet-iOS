//
//  StakingTransferCardSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import RxCocoa
import RxFeedback
import Extensions
import DomainLayer
import RxSwift

final class StakingTransferCardSystem: System<Staking.Card, Staking.Card.Event> {
    
    override func reduce(event: Staking.Card.Event, state: inout Staking.Card) {
        
        switch event {
        case .input(let money, let indexPath):
            break
            
        case .tapAssistanceButton(let button):
            break
            
        case .tapSendButton:
            break
            
        case .viewDidAppear:
            break
        case .showCard:
            break
        }
    }
}
