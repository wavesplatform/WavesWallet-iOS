////
////  StakingTransferCardUISystem.swift
////  WavesWallet-iOS
////
////  Created by rprokofev on 27.02.2020.
////  Copyright © 2020 Waves Platform. All rights reserved.
////
//
//import Foundation
//import RxCocoa
//import RxFeedback
//import Extensions
//import DomainLayer
//import RxSwift
//
//final class StakingTransferCardUISystem: System<StakingTransfer.UI, StakingTransfer.UI.Event> {
//    
//    let coreSystem: System<StakingTransfer.Card, StakingTransfer.Card.Event> = StakingTransferCardSystem()
//    
//    let disposeBag: DisposeBag = DisposeBag()
//    
//    override func initialState() -> StakingTransfer.UI! {
//        return StakingTransfer.UI.init(state: StakingTransfer.UI.State.init(sections: [],
//                                                                            title: "",
//                                                                            action: .none),
//                                       command: .none)
//    }
//    
//    override func reduce(event: StakingTransfer.UI.Event, state: inout StakingTransfer.UI) {
//
//        state.state.action = .none
//        
//        switch event {
//        case .viewDidAppear:
//            state.command = .viewDidAppear
//
//        case .tapSendButton:
//            state.command = .tapSendButton
//
//        case .tapAssistanceButton(let assistanceButton):
//            state.command = .tapAssistanceButton(assistanceButton)
//
//        case .input(let money, let indexPath):
//            state.command = .input(money, indexPath)
//
//        case .update(let stateUI):
//            
//            state.state = stateUI
//            state.command = nil
//        }
//    }
//    
//    override func internalSystem(driver: SharedSequence<DriverSharingStrategy, StakingTransfer.UI>) {
//                
//        coreSystem
//            .start()
//            .drive(onNext: { [weak self] (state) in
//                
//                guard state.setNeedUpdateUI else { return }
//                guard let uiState = state.uiState else { return }
//                
//                
//                self?.send(.update(uiState))
//            })
//            .disposed(by: disposeBag)
//        
//        driver
//            .drive(onNext: { [weak self] (ui) in
//                
//                guard let coreEvent = ui.command?.event else { return }
//                
//                self?.coreSystem.send(coreEvent)
//            })
//            .disposed(by: disposeBag)
//    }
//}
//
//fileprivate extension StakingTransfer.UI.Command {
//    
//    var event: StakingTransfer.Card.Event {
//        switch self {
//        case .input(let money, let indexPath):
//            return .input(money, indexPath)
//
//        case .tapAssistanceButton(let assistanceButton):
//            return .tapAssistanceButton(assistanceButton)
//            
//        case .tapSendButton:
//            return .tapSendButton
//            
//        case .viewDidAppear:
//            return .viewDidAppear
//        }
//    }
//}
