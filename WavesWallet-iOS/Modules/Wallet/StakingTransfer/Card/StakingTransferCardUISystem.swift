//
//  StakingTransferCardUISystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 27.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import Extensions
import DomainLayer
import RxSwift

final class StakingTransferCardUISystem: System<Staking.UI, Staking.UI.Event> {
    
    let coreSystem: System<Staking.Card, Staking.Card.Event> = StakingTransferCardSystem()
    
    let disposeBag: DisposeBag = DisposeBag()
    
    override func reduce(event: Staking.UI.Event, state: inout Staking.UI) {
                        
        switch event {
        case .viewDidAppear:
            state.command = .viewDidAppear

        case .tapSendButton:
            state.command = .tapSendButton

        case .tapAssistanceButton(let assistanceButton):
            state.command = .tapAssistanceButton(assistanceButton)

        case .input(let money, let indexPath):
            state.command = .input(money, indexPath)

        case .update(let stateUI):
            state.state = stateUI
        }
    }
    
    override func internalSystem(driver: SharedSequence<DriverSharingStrategy, Staking.UI>) {
                
        coreSystem
            .start()
            .drive(onNext: { [weak self] (state) in
                
                guard let event = state.uiEvent else {
                    return
                }
                
                self?.send(event)
            })
            .disposed(by: disposeBag)
        
        driver
            .drive(onNext: { [weak self] (ui) in
                
                guard let coreEvent = ui.command?.event else { return }
                self?.coreSystem.send(coreEvent)
            })
            .disposed(by: disposeBag)
    }
}

fileprivate extension Staking.UI.Command {
    
    var event: Staking.Card.Event {
        switch self {
        case .input(let money, let indexPath):
            return .input(money, indexPath)

        case .tapAssistanceButton(let assistanceButton):
            return .tapAssistanceButton(assistanceButton)
            
        case .tapSendButton:
            return .tapSendButton
            
        case .viewDidAppear:
            return .viewDidAppear
        }
    }
}
