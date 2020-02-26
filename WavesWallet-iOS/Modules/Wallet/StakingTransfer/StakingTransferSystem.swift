//
//  StakingTransferSystem.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Foundation
import RxCocoa
import RxFeedback
import Extensions
import DomainLayer

final class StakingTransferSystem: System<StakingTransfer.State, StakingTransfer.Event> {
    
    private var kind: StakingTransfer.DTO.Kind = .card
    
    override func initialState() -> State! {

        
        let core: State.Core = State.Core(kind: self.kind,
                                          action: .none,
                                          data: nil,
                                          input: nil)
        
        let ui: State.UI = .initialState(kind: self.kind)
        
        return State(ui: ui,
                     core: core)
    }

    override func internalFeedbacks() -> [Feedback] {
        return [ShowCardQuery().feedBack]
        
    }

    override func reduce(event: Event, state: inout State) {
        
        switch event {
        case .viewDidAppear:
            
            switch state.core.kind {
            case .card:
                state.core.action = .loadCard
                
            case .deposit:
                state.core.action = .loadDeposit
                
            case .withdraw:
                state.core.action = .loadWithdraw
                
            }
        case .tapAssistanceButton(let assistanceButton):
            
            switch assistanceButton {
            case .max:
                break
            case .percent100:
                break
            case .percent75:
                break
            case .percent50:
                break
            case .percent25:
                break
            }
            
        case .input(let input, let indexPath):
            
            guard let card = state.core.data?.card else { return }
                        
            let prevInputCard = state.core.input?.card
            let minAmount = card.minAmount
            let maxAmount = card.maxAmount
            
            var error: StakingTransfer.DTO.InputCard.Error? = nil
             
            if let input = input {
                if input > maxAmount.money {
                    error = .maxAmount
                } else if input < minAmount.money {
                    error = .minAmount
                }
            }
            
            
//            let needRemoveError: Bool
                        
            state.core.input = .card(.init(amount: input, error: error))
            state.core.action = .none
            
            
            var inputCard = state.core.input?.card
            
            var sections = state.ui.sections
            var section = sections.first
//            section?.rows
            
            var insertRows: [IndexPath] = .init()
            var deleteRows: [IndexPath] = .init()
            var reloadRows: [IndexPath] = .init()
                                    
//            if hasPrevError && error != nil {
//                deleteRows.append(IndexPath(row: 1, section: 0))
//            }

//            if error != nil {
//
//            }
            
            let hasPrevError = prevInputCard?.error != nil
            let hasError = error != nil
            let reloadError = hasPrevError && hasError
            
            if hasPrevError {
                state.ui.remove(indexPath: IndexPath(row: 1, section: 0))
            }
                                                           
            if hasError {
                if let errorRow  = card.error(inputCard: inputCard) {
                    state.ui.add(row: errorRow, indexPath: IndexPath(row: 1, section: 0))
                }
            }
            
                        
            if reloadError {
                reloadRows.append(IndexPath(row: 1, section: 0))
            } else  {
                
                if hasPrevError {
                    deleteRows.append(IndexPath(row: 1, section: 0))
                }
                                             
                if hasError {
                    insertRows.append(IndexPath(row: 1, section: 0))
                }
            }
            
            
            state.ui.action = .updateRows(insertRows,
                                          deleteRows,
                                          reloadRows)
            
            
            
            break
        case .showCard(let card):
            
            state.core.action = .none
            state.core.data = .card(card)
            
            state.ui.sections = card.sections(inputCard: state.core.input?.card)
            state.ui.action = .update
            
        case .showDeposit(let deposit):
            break
            
        case .showWithdraw(let withdraw):
            break
        }
    }
}


private extension StakingTransferSystem {
    
}


private struct ShowCardQuery: SystemQuery {
    
    func react(state: StakingTransfer.State) ->  Self? {
        return state.core.action == .loadCard ? self : nil
    }
    
    func effects(query: Self) -> Signal<StakingTransfer.Event> {
        
        let balance: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
                                                                                            ticker: "USDN"),
                                                                            money: Money.init(0,
                                                                                              2))
        
        let max: DomainLayer.DTO.Balance = DomainLayer.DTO.Balance.init(currency: .init(title: "USDN",
                        ticker: "USDN"),
                                                                        money: Money.init(1000,
                                                                                          2))
        
        let card: StakingTransfer.DTO.Card = StakingTransfer.DTO.Card.init(asset: .init(id: "",
                                                                                        gatewayId: "",
                                                                                        wavesId: "",
                                                                                        name: "USDN",
                                                                                        precision: 2,
                                                                                        description: "",
                                                                                        height: 1,
                                                                                        timestamp: Date(),
                                                                                        sender: "",
                                                                                        quantity: 10,
                                                                                        ticker: "USDN",
                                                                                        isReusable: false,
                                                                                        isSpam: false,
                                                                                        isFiat: false,
                                                                                        isGeneral: false,
                                                                                        isMyWavesToken: false,
                                                                                        isWavesToken: false,
                                                                                        isGateway: false,
                                                                                        isWaves: false,
                                                                                        modified: Date(),
                                                                                        addressRegEx: "",
                                                                                        iconLogoUrl: nil,
                                                                                        hasScript: false,
                                                                                        minSponsoredFee: 10,
                                                                                        gatewayType: nil),
                                                                           minAmount: balance,
                                                                           maxAmount: max)
        
        return Signal.just(.showCard(card))
    }
}
